using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class RezervacijaProstoraService : BaseCrudService<RezervacijaProstora, RezervacijaProstoraSearchRequest, RezervacijaProstoraInsertRequest, RezervacijaProstoraUpdateRequest>
{
    public RezervacijaProstoraService(MojeAutoContext context) : base(context)
    {
    }
}