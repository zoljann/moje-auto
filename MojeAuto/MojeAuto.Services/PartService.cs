using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class PartService : BaseCrudService<Part, PartSearchRequest, PartInsertRequest, PartUpdateRequest>
{
    public PartService(MojeAutoContext context) : base(context) { }
    public override async Task<ServiceResult<Part>> Insert(PartInsertRequest insertRequest)
    {
        var manufacturerExists = await _context.Manufacturers.AnyAsync(m => m.ManufacturerId == insertRequest.ManufacturerId);
        var categoryExists = await _context.Categories.AnyAsync(c => c.CategoryId == insertRequest.CategoryId);

        if (!manufacturerExists)
            return ServiceResult<Part>.Fail("Invalid ManufacturerId");

        if (!categoryExists)
            return ServiceResult<Part>.Fail("Invalid CategoryId");

        var part = new Part();
        MapInsertRequestToEntity(insertRequest, part);

        _dbSet.Add(part);
        await _context.SaveChangesAsync();

        return ServiceResult<Part>.Ok(part);
    }
}
