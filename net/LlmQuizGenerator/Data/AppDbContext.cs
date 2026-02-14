using Microsoft.EntityFrameworkCore;

namespace LlmQuizGenerator.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<QuizSetEntity> QuizSets { get; set; }
    public DbSet<QuizLogEntity> QuizLogs { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<QuizSetEntity>()
            .Property(q => q.JsonData)
            .HasColumnType("TEXT"); // SQLite JSON as string

        modelBuilder.Entity<QuizLogEntity>()
            .Property(q => q.JsonData)
            .HasColumnType("TEXT");
    }
}