using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
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

    public virtual async Task<ServiceResult<IEnumerable<TEntity>>> Get(TSearch search, int? id = null)
    {
        if (id.HasValue)
        {
            var entity = await _dbSet.FindAsync(id.Value);
            if (entity == null)
                return ServiceResult<IEnumerable<TEntity>>.Fail("Entity not found.");

            return ServiceResult<IEnumerable<TEntity>>.Ok(new List<TEntity> { entity });
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

        if (search is BaseSearchRequest pagination && pagination.Page > 0 && pagination.PageSize > 0)
        {
            int skip = (pagination.Page - 1) * pagination.PageSize;
            query = query.Skip(skip).Take(pagination.PageSize + 1);
        }

        var list = await query.ToListAsync();

        if (!list.Any())
            return ServiceResult<IEnumerable<TEntity>>.Fail("No results found.");

        return ServiceResult<IEnumerable<TEntity>>.Ok(list);
    }

    public virtual async Task<ServiceResult<TEntity>> Insert(TInsert insertRequest)
    {
        var entity = new TEntity();

        MapInsertRequestToEntity(insertRequest, entity);

        _dbSet.Add(entity);
        await _context.SaveChangesAsync();

        return ServiceResult<TEntity>.Ok(entity);
    }

    public virtual async Task<ServiceResult<TEntity>> Update(int id, TUpdate updateRequest)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity == null)
            return ServiceResult<TEntity>.Fail("Entity not found.");

        MapUpdateRequestToEntity(updateRequest, entity);

        await _context.SaveChangesAsync();

        return ServiceResult<TEntity>.Ok(entity);
    }

    public virtual async Task<ServiceResult<bool>> Delete(int id)
    {
        var entity = await _dbSet.FindAsync(id);
        if (entity == null)
            return ServiceResult<bool>.Fail("Entity not found.");

        var entityType = typeof(TEntity);

        var referencingFks = _context.Model.GetEntityTypes()
            .SelectMany(et => et.GetForeignKeys())
            .Where(fk => fk.PrincipalEntityType.ClrType == entityType)
            .ToList();

        foreach (var fk in referencingFks)
        {
            var dependentType = fk.DeclaringEntityType.ClrType;
            var dependentSet = (IQueryable)_context.GetType()
                .GetMethod("Set", Type.EmptyTypes)!
                .MakeGenericMethod(dependentType)
                .Invoke(_context, null)!;

            var fkProp = fk.Properties.FirstOrDefault();
            if (fkProp == null) continue;

            var param = Expression.Parameter(dependentType, "x");
            var left = Expression.Property(param, fkProp.Name);
            var right = Expression.Constant(id);
            var body = Expression.Equal(left, right);
            var lambda = Expression.Lambda(body, param);

            var anyMethod = typeof(Queryable)
                .GetMethods()
                .First(m => m.Name == "Any" && m.GetParameters().Length == 2)
                .MakeGenericMethod(dependentType);

            var isReferenced = (bool)anyMethod.Invoke(null, new object[] { dependentSet, lambda })!;
            if (isReferenced)
                return ServiceResult<bool>.Fail($"Nije moguće obrisati jer se koristi u tabeli: {dependentType.Name}");
        }

        _dbSet.Remove(entity);
        await _context.SaveChangesAsync();
        return ServiceResult<bool>.Ok(true);
    }

    protected virtual void MapInsertRequestToEntity(TInsert insertRequest, TEntity entity)
    {
        if (insertRequest == null || entity == null)
            return;

        var insertProps = typeof(TInsert).GetProperties();
        var entityProps = typeof(TEntity).GetProperties();

        foreach (var insertProp in insertProps)
        {
            var entityProp = entityProps.FirstOrDefault(p => p.Name == insertProp.Name && p.CanWrite);

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
            var entityProp = entityProps.FirstOrDefault(p =>
            p.Name == updateProp.Name && p.CanWrite);
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