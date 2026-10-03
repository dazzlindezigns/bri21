/* ============================================================
   EDIT THIS FILE. Everything on the page reads from here.
   Loaded before the main script in index.html.
   ============================================================ */
const CONFIG = {
  signature: "Dani",
  departure: "2027-02-04T19:00:00-06:00",   // countdown target (Austin time)
  vrboUrl: "https://www.vrbo.com/5425883",
  ticketsUrl: "https://disneyworld.disney.go.com/admission/tickets/",
  housePerPerson: 150,                      // flat, ages 9+
  vanTotal: 9000,     vanIsEstimate: true,  // 20-passenger van + driver, Feb 4–11, incl. tip
  epcotTicket: 190,
  datwBudget: "$120–$160",
  minPayersForDisplay: 16,
  schedule: [
    { what: "Deposit (your house share)", amount: "house", due: "Nov 15, 2026", note: "Holds your spot. We book the house once enough deposits are in." },
    { what: "Half your van share", amount: "vanHalf", due: "Dec 15, 2026", note: "Locks in the van and driver." },
    { what: "The rest of your van share", amount: "vanHalf", due: "Jan 10, 2027", note: "Paid in full. Then you just pack." }
  ],
  pay: [
    { label: "Zelle (preferred)", value: "[add your Zelle phone or email]" },
    { label: "Cash App", value: "[add your $cashtag]" }
  ],
  memo: "BRI21 + your name",
  policy: "Deposits aren't refundable once the house is booked, because that money is already spent. If you can't make it, you can hand your spot to someone else and settle up with them.",
  supabase: { url: "", anonKey: "", table: "bri21_rsvps" }
};

const HOUSE_PHOTOS = [
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/1e6d2e47.jpg?impolicy=resizecrop&rw=1200&ra=fit", cap: "Pool" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/f00d806c.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Living room" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/5a852f8f.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Themed bedroom" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/fdf964fd.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Kids' room" },
  { src: "https://media.vrbo.com/lodging/135000000/134540000/134534700/134534642/d09a9457.jpg?impolicy=resizecrop&rw=600&ra=fit", cap: "Laundry" }
];
/* ============================================================ */
