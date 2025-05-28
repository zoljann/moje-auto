using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class ManufacturerService : BaseCrudService<Manufacturer, ManufacturerSearchRequest, ManufacturerInsertRequest, ManufacturerUpdateRequest>
{
    public ManufacturerService(MojeAutoContext context) : base(context) { }
}
