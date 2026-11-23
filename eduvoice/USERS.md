# Ready Alert demo accounts

Every seeded account uses the password **`ready123`**. Sign in with the
**School ID** or the email address (school ID + `@pnhs.edu.ph`).

- **Host** — creates, assigns and edits groups and users, and alerts every group.
- **Leader** — sends alerts to the one group they lead.
- **Member** — receives their leader's alerts, and can mute the siren or stop
  the alert on their own account.

The roster is created by `lib/core/database/seed_data.dart`, so a fresh install
(fresh `ready_alert.db`) always has these accounts.

## Host

| Name | School ID | Email |
| --- | --- | --- |
| Juan Dela Cruz | `juan.delacruz` | `juan.delacruz@pnhs.edu.ph` |

## Youth volunteer leaders

| Name | School ID | Email | Group led |
| --- | --- | --- | --- |
| Maria Santos | `maria.santos` | `maria.santos@pnhs.edu.ph` | Red Cross Youth A |
| Jose Reyes | `jose.reyes` | `jose.reyes@pnhs.edu.ph` | Red Cross Youth B |
| Ana Cruz | `ana.cruz` | `ana.cruz@pnhs.edu.ph` | Boy Scouts Troop 1 |
| Mark Lim | `mark.lim` | `mark.lim@pnhs.edu.ph` | Boy Scouts Troop 2 |

## Members

### Red Cross Youth A — led by Maria Santos

| Name | School ID | Email |
| --- | --- | --- |
| Andrea Bautista | `andrea.bautista` | `andrea.bautista@pnhs.edu.ph` |
| Carlo Mendoza | `carlo.mendoza` | `carlo.mendoza@pnhs.edu.ph` |
| Divine Ramos | `divine.ramos` | `divine.ramos@pnhs.edu.ph` |
| Elijah Torres | `elijah.torres` | `elijah.torres@pnhs.edu.ph` |
| Faith Villanueva | `faith.villanueva` | `faith.villanueva@pnhs.edu.ph` |
| Gabriel Aquino | `gabriel.aquino` | `gabriel.aquino@pnhs.edu.ph` |
| Hannah Salazar | `hannah.salazar` | `hannah.salazar@pnhs.edu.ph` |
| Ian Navarro | `ian.navarro` | `ian.navarro@pnhs.edu.ph` |
| Jasmine Dizon | `jasmine.dizon` | `jasmine.dizon@pnhs.edu.ph` |
| Kevin Padilla | `kevin.padilla` | `kevin.padilla@pnhs.edu.ph` |
| Liza Fernandez | `liza.fernandez` | `liza.fernandez@pnhs.edu.ph` |

### Red Cross Youth B — led by Jose Reyes

| Name | School ID | Email |
| --- | --- | --- |
| Miguel Castro | `miguel.castro` | `miguel.castro@pnhs.edu.ph` |
| Nicole Uy | `nicole.uy` | `nicole.uy@pnhs.edu.ph` |
| Oliver Garcia | `oliver.garcia` | `oliver.garcia@pnhs.edu.ph` |
| Patricia Lim | `patricia.lim` | `patricia.lim@pnhs.edu.ph` |
| Queenie Ramos | `queenie.ramos` | `queenie.ramos@pnhs.edu.ph` |
| Rafael Domingo | `rafael.domingo` | `rafael.domingo@pnhs.edu.ph` |
| Sofia Alonzo | `sofia.alonzo` | `sofia.alonzo@pnhs.edu.ph` |
| Tobias Rivera | `tobias.rivera` | `tobias.rivera@pnhs.edu.ph` |
| Ursula Bello | `ursula.bello` | `ursula.bello@pnhs.edu.ph` |

### Boy Scouts Troop 1 — led by Ana Cruz

| Name | School ID | Email |
| --- | --- | --- |
| Victor Pascual | `victor.pascual` | `victor.pascual@pnhs.edu.ph` |
| Wilma Espino | `wilma.espino` | `wilma.espino@pnhs.edu.ph` |
| Xavier Tan | `xavier.tan` | `xavier.tan@pnhs.edu.ph` |
| Yvonne Mercado | `yvonne.mercado` | `yvonne.mercado@pnhs.edu.ph` |
| Zander Ocampo | `zander.ocampo` | `zander.ocampo@pnhs.edu.ph` |
| Althea Rosales | `althea.rosales` | `althea.rosales@pnhs.edu.ph` |
| Benedict Silva | `benedict.silva` | `benedict.silva@pnhs.edu.ph` |

### Boy Scouts Troop 2 — led by Mark Lim

| Name | School ID | Email |
| --- | --- | --- |
| Carmela Reyes | `carmela.reyes` | `carmela.reyes@pnhs.edu.ph` |
| Dominic Chan | `dominic.chan` | `dominic.chan@pnhs.edu.ph` |
| Erika Lopez | `erika.lopez` | `erika.lopez@pnhs.edu.ph` |
| Francis Chua | `francis.chua` | `francis.chua@pnhs.edu.ph` |
| Grace Ong | `grace.ong` | `grace.ong@pnhs.edu.ph` |

**Totals:** 1 host, 4 leaders, 32 members — 37 accounts across 4 groups.

## Role test checklist

### 1. Host can run the roster and alert everyone

1. Sign in as `juan.delacruz` / `ready123`.
2. The `+` button offers **Add user** and **Add group**.
3. Send **Red** from the dial: the message says it reached 4 volunteer groups.
4. Open **Groups** → tap **Red Cross Youth A**: the group screen lists its
   leader and every member. Tap **Edit group** to rename it, change its status
   or choose another leader; tap any member to change their name, role or group.
5. Sign in as `maria.santos` and confirm a renamed/moved account still uses its
   original school ID.
6. Open **Settings → Edit my details** and change your own name, email and
   contact number. The role stays the same; only the host changes roles.

### 2. Leader only alerts their own group

1. Sign in as `maria.santos` / `ready123`.
2. The `+` add menu is gone; the send button is still available.
3. Send **Yellow**. Members of Red Cross Youth A receive it; nobody in Red Cross
   Youth B or the Boy Scouts groups does.
4. The snackbar names the single group reached.

### 3. Member receives, mutes and stops

1. First, as `maria.santos`, send **Red**.
2. Sign in as `andrea.bautista` / `ready123`: the live alert replaces the dial.
3. Tap the speaker button to **mute**; the alert stays live and the choice is
   remembered after signing out and back in.
4. Tap **Stop**: the alert disappears for Andrea only.
5. Sign in as `carlo.mendoza`: the alert is still live for him.
6. Sign in as `miguel.castro` (Red Cross Youth B): he never saw Maria's alert.

### 4. Editing is host-only

1. Sign in as `maria.santos` or `andrea.bautista`.
2. Groups can be opened to view the leader and members, but there is no
   **Edit group** button and no add menu.
3. The roster repository rejects leader/member writes even if a screen is
   bypassed (`RosterRepository.createUser` / `updateUser` / `updateGroup`).
4. Any account can edit its own name, email and contact number in Settings,
   but has no control over its role or group.

### 5. Online alerts with Firebase

Run two devices or two browser windows with the same `FIREBASE_*` dart-defines
(see the README). Sign in as the host on one and a group member on the other,
then send an alert. The member's dashboard should show the live alert within a
few seconds, and stopping it as the sender should clear it on both.
