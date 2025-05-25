using Microsoft.EntityFrameworkCore;
using MojeAuto.Model;
using MojeAuto.Services.Database;
using System.Linq.Expressions;

public class BaseCrudService<TEntity, TSearch, TInsert, TUpdate> : IBaseCrudService<TEntity, TSearch, TInsert, TUpdate>
    where TEntity : class, new()
{
    protected readonly MojeAutoContext _context;
    protected readonly DbSet<TEntity> _dbSet;

    public BaseCrudService(MojeAutoContext context)
    {
        _context = context;
        _dbSet = _context.Set<TEntity>();
    }
    public virtual async Task<IEnumerable<TEntity>> Get(TSearch search, int? id = null)
    {
        if (id.HasValue)
        {
            var entity = await _dbSet.FindAsync(id.Value);
            if (entity == null)
                return Enumerable.Empty<TEntity>();
            return new List<TEntity> { entity };
        }

        var query = _dbSet.AsQueryable();

        if (search != null)
        {
            foreach (var prop in typeof(TSearch).GetProperties())
            {
                var value = prop.GetValue(search);
                if (value == null) continue;

                var entityProp = typeof(TEntity).GetProperty(prop.Name);
                if (entityProp == null) continue;

                var parameter = Expression.Parameter(typeof(TEntity), "e");
                var left = Expression.Property(parameter, entityProp);
                var right = Expression.Constant(value);
                Expression body;

                if (entityProp.PropertyType == typeof(string))
                {
                    var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) })!;
                    body = Expression.Call(left, containsMethod, right);
                }
                else
                {
                    body = Expression.Equal(left, right);
                }

                var predicate = Expression.Lambda<Func<TEntity, bool>>(body, parameter);
                query = query.Where(predicate);
            }
        }

        return await query.ToListAsync();
    }



    public virtual async Task<TEntity> Insert(TInsert insertRequest)
    {
        var entity = new TEntity();

        MapInsertRequestToEntity(insertRequest, entity);

        _dbSet.Add(entity);
        await _context.SaveChangesAsync();

        return entity;
    }
    public virtual async Task<bool> Update(int id, TUpdate updateRequest)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity == null)
            return false;

        MapUpdateRequestToEntity(updateRequest, entity);

        await _context.SaveChangesAsync();
        return true;
    }

    public virtual async Task<bool> Delete(int id)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity == null)
            return false;

        _dbSet.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }
    protected virtual void MapInsertRequestToEntity(TInsert insertRequest, TEntity entity)
    {
        if (insertRequest == null || entity == null)
            return;

        var insertProps = typeof(TInsert).GetProperties();
        var entityProps = typeof(TEntity).GetProperties();

        foreach (var insertProp in insertProps)
        {
            var entityProp = entityProps.FirstOrDefault(p => p.Name == insertProp.Name && p.PropertyType == insertProp.PropertyType && p.CanWrite);
            if (entityProp == null)
                continue;

            var value = insertProp.GetValue(insertRequest);

            if (value != null)
            {
                entityProp.SetValue(entity, value);
            }
        }
    }

    protected virtual void MapUpdateRequestToEntity(TUpdate updateRequest, TEntity entity)
    {
        if (updateRequest == null || entity == null)
            return;

        var updateProps = typeof(TUpdate).GetProperties();
        var entityProps = typeof(TEntity).GetProperties();

        foreach (var updateProp in updateProps)
        {
            var entityProp = entityProps.FirstOrDefault(p => p.Name == updateProp.Name && p.PropertyType == updateProp.PropertyType && p.CanWrite);
            if (entityProp == null)
                continue;

            var value = updateProp.GetValue(updateRequest);

            if (value != null)
            {
                entityProp.SetValue(entity, value);
            }
        }
    }
}
