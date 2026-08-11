using DataEntities;
using Microsoft.EntityFrameworkCore;

namespace Products.Models;

public class Context(DbContextOptions options) : DbContext(options)
{
    public DbSet<Product> Product => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(entity =>
        {
            entity.Property(product => product.Price).HasPrecision(18, 2);
        });

        base.OnModelCreating(modelBuilder);
    }
}