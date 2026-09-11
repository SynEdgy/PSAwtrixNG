using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using MQTTnet.Server;

namespace PSAwtrixNG.Mqtt
{
    public sealed class CapturedMqttMessage
    {
        public string ClientId { get; set; }

        public string Topic { get; set; }

        public string Payload { get; set; }

        public byte[] PayloadBytes { get; set; }

        public int QualityOfServiceLevel { get; set; }

        public bool Retain { get; set; }

        public DateTimeOffset ReceivedAt { get; set; }
    }

    public sealed class MqttBrokerCapture
    {
        private readonly ConcurrentQueue<CapturedMqttMessage> messages =
            new ConcurrentQueue<CapturedMqttMessage>();

        public int Count
        {
            get { return messages.Count; }
        }

        public void Attach(MqttServer server)
        {
            if (server == null)
            {
                throw new ArgumentNullException(nameof(server));
            }

            server.InterceptingPublishAsync += CaptureMessageAsync;
        }

        public CapturedMqttMessage[] Drain()
        {
            var capturedMessages = new List<CapturedMqttMessage>();
            CapturedMqttMessage message;

            while (messages.TryDequeue(out message))
            {
                capturedMessages.Add(message);
            }

            return capturedMessages.ToArray();
        }

        private Task CaptureMessageAsync(InterceptingPublishEventArgs eventArgs)
        {
            var payload = eventArgs.ApplicationMessage.Payload ?? new byte[0];

            messages.Enqueue(
                new CapturedMqttMessage
                {
                    ClientId = eventArgs.ClientId,
                    Topic = eventArgs.ApplicationMessage.Topic,
                    Payload = Encoding.UTF8.GetString(payload),
                    PayloadBytes = payload,
                    QualityOfServiceLevel = (int)eventArgs.ApplicationMessage.QualityOfServiceLevel,
                    Retain = eventArgs.ApplicationMessage.Retain,
                    ReceivedAt = DateTimeOffset.UtcNow
                });

            return Task.CompletedTask;
        }
    }
}
