using System.Collections.Generic;
using System.Threading.Tasks;

namespace MojeAuto.Model
{
    public interface IBaseCrudService<TEntity, TSearch, TInsert, TUpdate>
        where TEntity : class
    {
        Task<IEnumerable<TEntity>> Get(TSearch search, int? id);
        Task<TEntity> Insert(TInsert insertRequest);
        Task<bool> Update(int id, TUpdate updateRequest);
        Task<bool> Delete(int id);
    }
}
