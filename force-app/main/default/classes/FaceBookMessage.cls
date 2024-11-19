public class FaceBookMessage {
  public String objects { get; set; }
    public List<Entry> entry { get; set; }

    public class Entry {
        public Long times { get; set; }
        public String id { get; set; }
        public List<Messaging> messaging { get; set; }
    }

    public class Messaging {
        public Sender sender { get; set; }
        public Recipient recipient { get; set; }
        public Long timestamp { get; set; }
        public Message message { get; set; }
    }

    public class Sender {
        public String id { get; set; }
    }

    public class Recipient {
        public String id { get; set; }
    }

    public class Message {
        public String mid { get; set; }
        public String text { get; set; }
    }

}