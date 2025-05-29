namespace MojeAuto.Model.Common
{
    public interface IBaseCrudService<TEntity, TSearch, TInsert, TUpdate>
        where TEntity : class
    {
        Task<ServiceResult<IEnumerable<TEntity>>> Get(TSearch search, int? id = null);

        Task<ServiceResult<TEntity>> Insert(TInsert insertRequest);

        Task<ServiceResult<TEntity>> Update(int id, TUpdate updateRequest);

        Task<ServiceResult<bool>> Delete(int id);
    }
}