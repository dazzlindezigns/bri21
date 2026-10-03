/* ============================================================
   EDIT THIS FILE. Everything on the page reads from here.
   Loaded before the main script in index.html.
   ============================================================ */
const CONFIG = {
  signature: "Dani",
  departure: "2027-02-04T20:00:00-06:00",   // countdown target (Austin time). Rolling out around 8 or 9pm
  vrboUrl: "https://www.vrbo.com/5425883",
  ticketsUrl: "https://disneyworld.disney.go.com/admission/tickets/",
  spots: 20,                                // spots for ages 9 and up (under 9 don't count). A spot is held once the deposit is logged
  housePerPerson: 150,                      // flat, ages 9+
  // Van: flat per-person ESTIMATE so the whole trip lands at $500/person (house $150 + van $350).
  // We're still shopping van rates. When a real quote comes in, change vanPerPerson
  // and set vanIsEstimate: false to drop the estimate warnings.
  vanPerPerson: 350,  vanIsEstimate: true,  // 20-passenger van + driver, Feb 4–11
  estimateNote: "The $500 is an estimate. The $150 house share is locked in, but we're still shopping for the best van rate, so the van part can change. We'll update this page as soon as it's final.",
  epcotTicket: 190,
  datwBudget: "$120–$160",
  schedule: [
    { what: "Deposit (your house share)", amount: "house", due: "Nov 15, 2026", note: "Holds your spot. We book the house once enough deposits are in." },
    { what: "Half your van share", amount: "vanHalf", due: "Dec 15, 2026", note: "Locks in the van and driver." },
    { what: "The rest of your van share", amount: "vanHalf", due: "Jan 10, 2027", note: "Paid in full. Then you just pack." }
  ],
  pay: [
    { label: "Cash App", value: "$bri21celebration", url: "https://cash.app/$bri21celebration" }
  ],
  memo: "BRI21 + your name",
  giftMemo: "BRI21 GIFT + your name",       // "can't make it" gifts go toward the trip; memo keeps them separate from people's shares
  adminEmail: "danielle.washington21@gmail.com", // only this login can open /admin.html (enforced by Supabase policies, not just this line)
  policy: "Deposits aren't refundable once the house is booked, because that money is already spent. If you can't make it, you can hand your spot to someone else and settle up with them.",
  supabase: {
    url: "https://kpgvrntpigvtgyrzmfba.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwZ3ZybnRwaWd2dGd5cnptZmJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzNzQ1OTcsImV4cCI6MjA5MTk1MDU5N30.6g4rjiDbUmbM2A3I5fzQUzxHxF3PQ_QuRRMrT20RHzs", // public anon key, safe in client code
    table: "bri21_rsvps"
  }
};

const HOUSE_PHOTOS = [
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/1e6d2e47.jpg?impolicy=resizecrop&rw=1200&ra=fit", cap: "Pool" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/f00d806c.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Living room" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/5a852f8f.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Themed bedroom" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/fdf964fd.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Kids' room" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/d09a9457.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Laundry" }
];
/* ============================================================ */
