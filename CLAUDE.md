# Bri's 21st — Trip Site (Claude Code handoff)

## What this is
An invitation, itinerary, and RSVP site for a family road trip celebrating Bri's 21st birthday.
- **Trip:** Austin, TX to Kissimmee, FL. The van leaves Austin Thu Feb 4, 2027 (evening). House stay is Feb 5–10. Everyone is home Thu Feb 11.
- **The main event:** Drink Around the World at EPCOT on **Tue Feb 9, 2027** (Bri's birthday).
- **Audience:** family members opening the link from a text message, mostly on phones. Not technical.
- **Owner:** Dani. She knows GitHub, Vercel, Supabase, and Stripe well, so don't explain them to her. Ask before anything destructive.

## Current state (already in this folder)
- `index.html` is a complete single-file site: design, copy, and RSVP logic. The two photos of Bri are embedded as base64 JPEGs. All editable values live in the `CONFIG` object near the top of the `<script>`.
- `schema.sql` is the Supabase table `bri21_rsvps` with RLS and column grants.
- The RSVP list reads and writes through Supabase REST using `fetch`, with no SDK. It polls every 30s.

## Design rules (do not drift)
- The look is dark night background, neon pink glow, chrome/silver display type, and pink-paper cards. Palette and tokens are in `:root`.
- Fonts: **Anton** (display), **Yellowtail** (neon script), **Bricolage Grotesque** (body). **Never use the Syne font. It's permanently banned for Dani's builds.**
- No Disney characters, Mickey/Minnie shapes, or Disney park imagery. Those are trademarks. Crown, passport, and neon country signs are the motifs.
- Copy voice is Dani's: warm, direct, a little sassy ("Liiisten", "I'm not playing games", "Who all over there?"). Keep it. Don't make it corporate.
- Mobile-first. Test at 390px wide. Keep visible focus states and support `prefers-reduced-motion`.

## Hard guardrails
1. **The Supabase project is SHARED** with Dani's other live apps (Snaplist, Bri's booking app, KJ's DJ app). Only create or alter objects prefixed `bri21_`. **Never modify, drop, or migrate any other table, policy, function, bucket, or auth setting.** Read-only inspection is fine.
2. The anon key is public by design. Never put the service role key in client code or commit it.
3. No payment processing in the site (no Stripe checkout). Payments go by Cash App (`$bri21celebration`) outside the site. No Zelle. Dani logs them.
4. Don't invent prices or facts. (The $500/person total is Dani's own target estimate.) Values marked as estimates stay estimates until Dani gives real numbers.

## Tasks (in order)

### P0: Ship it
1. **Restructure lightly:** move `CONFIG` and `HOUSE_PHOTOS` into `config.js`, loaded before the main script, so Dani can edit values without touching layout. Move the base64 photos out to `/images/bri-1.jpg` and `/images/bri-2.jpg`. Keep it a static site with no framework and no build step unless one is truly needed.
2. **Git + Vercel with auto-deploy:**
   - `git init`, then `gh repo create bri21 --private --source=. --push`.
   - `vercel link`, connect the GitHub repo so every push to `main` auto-deploys to production, then `vercel --prod` for the first deploy.
   - After this, the workflow is: commit, push, and it's live. Confirm the production URL with Dani.
3. **Supabase:**
   - Ask Dani for the project URL and anon key (shared project). Put them in `config.js`.
   - Run `schema.sql` (via the Supabase CLI or have Dani paste it into the SQL editor). If `bri21_rsvps` already exists, run only the migration block at the bottom.
   - **RLS audit (read-only):** list every table in `public` with `relrowsecurity = false`. Report them to Dani. Do NOT change them. This page exposes the project URL to the whole family, so she needs to know.
   - Verify that an anonymous user can insert as thinking/coins/pending, can't insert as in/paid, can't read `amount_paid`, and can't update or delete.
4. **Fill in placeholders** (ask Dani for each one): Zelle handle, Cash App cashtag, real van total once quoted, and the departure time if different from Feb 4 at 7pm Central.

### P1: Make it easy for Dani
5. **`/admin.html`, a mobile payment logger.** This is the main way Dani updates statuses and payments, fast, from her phone.
   - Supabase Auth magic link. Only Dani's email is allowed (ask her for it). Add `bri21_` policies so `authenticated` users whose `auth.jwt()->>'email'` equals her email can select all columns and update `status` and `amount_paid`. Don't touch the shared project's other auth config.
   - UI: list of RSVPs with a tap to set status (Interested / Checking coins / Coming / Locked in / Paid in full) and a quick "+ payment" amount field that adds to `amount_paid`. Show totals: collected so far vs. expected (paying heads × per-person share), and who's behind on each due date.
   - Optional: a `bri21_payments` ledger table (rsvp_id, amount, method, note, created_at) with `amount_paid` kept as a sum. Use it only if it stays simple.
6. **House photos:** Vrbo images are hotlinked and may break. Ask Dani for 4–5 saved photos (pool, living room, game room, a themed bedroom). Put them in `/images/house/` and point `HOUSE_PHOTOS` at them.
7. **Link previews:** DONE: `og.jpg` is Dani's flyer (1000×1000, kept under 300KB so WhatsApp shows it). family will share this by text, so add Open Graph and Twitter meta tags with a 1200×630 `og.jpg`. Generate it in the site's style (chrome "BRI'S 21st", neon, date line) and include Bri's photo only if Dani approves.

### P2: Nice to have
8. Supabase Realtime instead of polling on the RSVP list.
9. An "Add to calendar" .ics button for Feb 4 departure and Feb 9 EPCOT.
10. A custom domain if Dani wants one.

## Trip facts (source of truth)
- **House:** 9BR at Encore Resort at Reunion (Vrbo 5425883). $150 flat per person ages 9+, for 5 nights.
- **Kids under 9:** free for the house and van. Disney tickets are free under 3.
- **Van:** 20-passenger with driver, for the full trip including the Austin round trip. Priced as a flat **$350/person ESTIMATE** (`vanPerPerson`, `vanIsEstimate: true`) so the whole trip is ~$500/person with the house. Dani is still shopping rates; the page must keep saying it's an estimate until she gives a real number.
- **EPCOT:** guests buy their own standard ticket for Feb 9 (~$190 estimate). Drink Around the World budget is $120–160 for 11 drinks. Annual passholders need a park reservation; date-based tickets don't. Under-21s are welcome but can't drink. 21+ need photo ID.
- **Itinerary:**
  - Feb 4: roll out from Austin
  - Feb 5: arrive, groceries, chill
  - Feb 6: fun day + night out
  - Feb 7: mall/shopping
  - Feb 8: Disney Springs + midnight toast
  - Feb 9: EPCOT, Drink Around the World
  - Feb 10: checkout + ride home
  - No church on the itinerary.
- **Payments:**
  - Deposit = $150 house share, due Nov 15, 2026
  - Half the van share, due Dec 15, 2026
  - The rest of the van share, due Jan 10, 2027
  - Memo line: "BRI21 + your name"
  - Deposits are nonrefundable once the house is booked; people can transfer their spot.
- **Departure:** Thu Feb 4, 2027, around 8–9pm Central (countdown targets 8pm).
- **Gifts:** "can't make it" gifts go toward the trip, not to Bri. People who want to gift Bri personally contact her directly.
- **House photos:** Dani wants them hotlinked from the Vrbo listing (decided Oct 2026). Broken images already hide themselves.
- **Admin:** `/admin.html`, magic link for danielle.washington21@gmail.com only. Policies are the ADMIN block in `schema.sql`.
- **RSVP statuses:** `thinking` (Interested), `coins` (Checking coins), `pending` (Coming), and `gift` (Sending love: can't make it, sending a gift) can be set by the public. `in` (Locked in) and `paid` (Paid in full) are set by Dani only. `gift` rows are never riders and never count toward the van split.
- **Cash App:** `$bri21celebration`. Trip memo `BRI21 + your name`; gift memo `BRI21 GIFT + your name`.

## Definition of done
- Live on Vercel, auto-deploying from `main`.
- RSVPs save and display for an anonymous visitor on a phone.
- Dani can log a payment from `/admin.html` in under 10 seconds.
- RLS audit reported. No non-`bri21_` objects changed.
- No Syne anywhere. No Disney character imagery.
