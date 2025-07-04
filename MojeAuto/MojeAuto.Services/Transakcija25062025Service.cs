using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;
using System.IO;

public class Transakcija25062025Service : BaseCrudService<Transakcija25062025, Transakcija25062025SearchRequest, Transakcija25062025InsertRequest, Transakcija25062025UpdateRequest>
{
    public Transakcija25062025Service(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<Transakcija25062025>> Insert(Transakcija25062025InsertRequest insertRequest)
    {
        var userId = insertRequest.UserId;
        var month = insertRequest.Datum.Month;

        var monthlyLimit = await _context.FinancijskiLimit25062025
            .Where(x => x.UserId == userId && x.Mjesec == month && x.KategorijaTransakcije25062025Id == insertRequest.KategorijaTransakcije25062025Id)
            .FirstOrDefaultAsync();

        if (monthlyLimit != null)
        {
            var totalSpent = await _context.Transakcija25062025
                .Where(t => t.UserId == userId
                         && t.Datum.Month == month
                         && t.KategorijaTransakcije25062025Id == insertRequest.KategorijaTransakcije25062025Id)
                .SumAsync(t => (decimal?)t.Amount);

            var newTotal = totalSpent + insertRequest.Amount;

            if (newTotal > monthlyLimit.Limit)
            {
                return ServiceResult<Transakcija25062025>.Fail("Prešli ste mjesečni limit.");
            }
            else if (newTotal >= monthlyLimit.Limit * 0.9m)
            {
                Console.WriteLine("Potrosili ste preko 90% mjesečnog limita");
            }
        }

        var transakcija = new Transakcija25062025
        {
            UserId = userId,
            Amount = insertRequest.Amount,
            Datum = insertRequest.Datum,
            Opis = insertRequest.Opis,
            KategorijaTransakcije25062025Id = insertRequest.KategorijaTransakcije25062025Id,
            Status = insertRequest.Status,
        };

        _dbSet.Add(transakcija);
        await _context.SaveChangesAsync();

        return ServiceResult<Transakcija25062025>.Ok(transakcija);
    }


    public override async Task<ServiceResult<Transakcija25062025>> Update(int id, Transakcija25062025UpdateRequest request)
    {
        var transaction = await _context.Transakcija25062025
            .FirstOrDefaultAsync(o => o.Transakcija25062025Id == id);

        if (transaction == null)
            return ServiceResult<Transakcija25062025>.Fail("Transakcija nije pronađena.");

        var log = new TransakcijaLog25062025
        {
            UserId = request.UserId,
            StariStatus = transaction.Status,
            NoviStatus = request.Status,
            VrijemePromjene = DateTime.Now
        };

        transaction.Status = request.Status;
        transaction.Opis = request.Opis;
        transaction.KategorijaTransakcije25062025Id = request.KategorijaTransakcije25062025Id;

        _context.TransakcijaLog25062025.Add(log);
        _context.Transakcija25062025.Update(transaction);

        await _context.SaveChangesAsync();

        return ServiceResult<Transakcija25062025>.Ok(transaction);
    }
}