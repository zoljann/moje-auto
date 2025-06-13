using MimeKit;
using MimeKit.Text;
using MailKit.Net.Smtp;
using MailKit.Security;

namespace MojeAuto.Consumer
{
    public class MailService
    {
        public void Send(string toEmail, string subject, string body)
        {
            var smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
            var smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587");
            var smtpUser = Environment.GetEnvironmentVariable("SMTP_USERNAME")
                ?? throw new Exception("Missing SMTP_USERNAME");
            var smtpPass = Environment.GetEnvironmentVariable("SMTP_PASSWORD")
                ?? throw new Exception("Missing SMTP_PASSWORD");

            var email = new MimeMessage();
            email.From.Add(MailboxAddress.Parse(smtpUser));
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = subject;
            email.Body = new TextPart(TextFormat.Plain) { Text = body };

            using var smtp = new SmtpClient();
            smtp.Connect(smtpServer, smtpPort, SecureSocketOptions.StartTls);
            smtp.Authenticate(smtpUser, smtpPass);
            smtp.Send(email);
            smtp.Disconnect(true);

            Console.WriteLine($"Email sent to: {toEmail}");
        }
    }
}