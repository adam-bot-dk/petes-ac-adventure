# Pete's AC Adventure - Game Design Document

## 1. CONCEPT OVERVIEW

**Working Title:** Pete's AC Adventure  
**Genre:** One-thumb Endless Runner  
**Target Platform:** iOS App Store (Android later)  
**Target Audience:** General audience, ages 8+  
**Play Session:** 30-120 seconds average

**Core Hook:** Help Pete the penguin deliver cool air on hot summer days while earning real-world discounts on AC service.

---

## 2. GAMEPLAY

### Controls
| Input | Action |
|-------|--------|
| Tap any screen | Jump |
| Hold down | Slide under obstacles |
| Double-tap | Dash (unlock at 5000 coins) |
| Pause button (P) | Pause game |

### Core Loop
1. **Run** - Pete runs automatically through city
2. **Dodge** - Jump over or slide under obstacles
3. **Collect** - Gather coins and energy stars
4. **Power Up** - Activate special abilities
5. **Survive** - Beat high score for bigger coupons
6. **Redeem** - Convert coins to AC service discounts

---

## 3. SCORING SYSTEM

### Base Scoring
- **Distance:** 1 meter = 10 points
- **Coins:** Each coin = 10 points
- **Stars:** Each star = 100 points

### Bonuses
- **Perfect Run:** No hits = +500 bonus
- **Daily Streak:** +10% for consecutive days
- **Power-ups:** Bonus points for collection

### Score Display
- Real-time score counter in HUD
- Final score shown on Game Over
- Leaderboard integration (future)

---

## 4. COLLECTIBLES

### Coins
- **Value:** 10 coins each
- **Appearance:** Golden dollar sign
- **Effect:** Increase coupon value
- **Group Spawn:** 3-7 coins per cluster

### Energy Stars
- **Value:** 1 star each
- **Appearance:** Blue five-point star
- **Effect:** Educational HVAC tip popup
- **Frequency:** 1 star per ~200m

### Power-ups
| Power-up | Effect | Duration | Visual |
|----------|--------|----------|--------|
| Ice Burst | Freeze obstacles | 3s | Blue icon |
| Turbo Vents | Auto-collect coins | 10s | Cyan icon |
| Service Van | Invincibility | 5s | White icon |
| Pete Clone | Double coins | 15s | Yellow icon |

---

## 5. OBSTACLES

### Obstacle Types (ordered by difficulty)

#### 1. Pothole (Easy)
- **Size:** 80x48
- **Action:** Jump over
- **Spawn Rate:** High (30%)
- **Description:** Dark hole in sidewalk

#### 2. Hot Puddle (Easy-Medium)
- **Size:** 80x48
- **Action:** Jump over OR slide under
- **Spawn Rate:** Medium (25%)
- **Description:** Orange steam puddle

#### 3. AC Unit (Medium)
- **Size:** 80x64
- **Action:** Jump only
- **Spawn Rate:** Medium (15%)
- **Description:** Grey box, high obstacle

#### 4. Bird (Medium)
- **Size:** 60x48
- **Action:** Slide under
- **Spawn Rate:** Medium (15%)
- **Description:** Small flying obstacle

#### 5. Traffic Cone (Medium-Hard)
- **Size:** 50x48
- **Action:** Jump or dodge
- **Spawn Rate:** Low (10%)
- **Description:** Orange construction cone

#### 6. Truck (Hard)
- **Size:** 120x96
- **Action:** Jump only, slow moving
- **Spawn Rate:** Low (5%)
- **Description:** Large delivery truck

### Spawn Logic
- **Initial Spawn:** Every 2.0-3.5 seconds
- **Speed Scaling:** Spawns faster as game speeds up
- **Placement:** Random Y position (200-1000)
- **Overlap Prevention:** Minimum 50px between obstacles

---

## 6. PROGRESSION SYSTEM

### Vehicle Unlock Tree
| Vehicle | Unlock Cost | Visual Change |
|---------|-------------|---------------|
| Foot (Pete walking) | Start | Default |
| Service Scooter | 500 coins | Pete rides scooter |
| Service Van | 2000 coins | Pete in van sprite |
| Work Truck | 5000 coins | Larger truck sprite |
| Branded Drone | 10000 coins | Flying drone |

### Daily Challenges
| Challenge | Reward |
|-----------|--------|
| Run 500m without sliding | +100 coins |
| Collect 20 stars | +200 coins |
| Survive 3 minutes | +300 coins |
| Hit 5 power-ups | +150 coins |

### Leaderboards (Future)
- Global leaderboard (all-time score)
- City-specific (Pure Heating fans)
- Friend leaderboard (Game Center)

---

## 7. PROGRESSIVE DIFFICULTY

### Speed Scaling
| Run Time | Speed | Notes |
|----------|-------|-------|
| 0-30s | 300px/s | Tutorial zone |
| 30-60s | 350px/s | Moderate |
| 60-120s | 450px/s | Fast |
| 120s+ | 550px/s | Expert |

### Obstacle Density
- **Early:** 1 obstacle per spawn cycle
- **Mid:** 1-2 obstacles per cycle
- **Late:** 2-3 obstacles per cycle

---

## 8. REAL-WORLD INTEGRATION

### Coupon System
| Coins Earned | Discount | Benefits |
|--------------|----------|----------|
| 1000 | $1 off | Any service |
| 5000 | $5 off | Priority scheduling |
| 10000 | $10 off | Free thermostat check |

### Redemption Flow
1. Player earns coins in-game
2. Tap "Redeem Coupon" on Game Over
3. Unique QR code generated
4. Show code to Pure Heating & Air staff
5. Staff scans code, applies discount

### Marketing Integration
- QR code on service trucks
- Business cards at customer calls
- Email signature link
- Social media weekly leaderboards

---

## 9. ART DIRECTION

### Visual Style
- **Format:** 2D vector art (clean, scalable)
- **Palette:** Bright, colorful, family-friendly
- **Brand Colors:** Red/white/blue (Pure Heating)
- **No Complex:** Avoid heavy shadows, realistic lighting

### Character Designs

#### Pete (Main Character)
- **Base:** Penguin (black/white)
- **Outfit:** Pure Heating branded tool vest
- **Accessories:** Wrench or clipboard
- **Expressions:** Happy, surprised, dizzy (hit)

#### Obstacles
- **Pothole:** Dark circle with crack details
- **Hot Puddle:** Orange with steam particles
- **AC Unit:** Grey box with fan details
- **Bird:** Simple silhouette
- **Cone:** Orange with white stripe
- **Truck:** Branded delivery truck

### Backgrounds (3 Parallax Layers)
1. **Far (Slowest):** City skyline silhouette
2. **Mid (Medium):** Buildings, HVAC units
3. **Foreground (Fastest):** Ground, street markings

---

## 10. AUDIO DESIGN

### Music
| Track | Mood | BPM | Use |
|-------|------|-----|-----|
| Main Theme | Upbeat, summery | 120 | Gameplay |
| Pause Menu | Calm version | 80 | Menu |
| Game Over | Sad but fun | 100 | Game Over |
| Victory | Energetic | 140 | Win/Continue |

### Sound Effects
| Action | SFX |
|--------|-----|
| Jump | Whoosh |
| Slide | Swish |
| Coin Collect | Cha-ching |
| Star Collect | Sparkle chime |
| Power-up | Ice freeze or turbo whoosh |
| Obstacle Hit | Bonk (cartoon) |
| Lives Lost | Ding-ding-ding |
| Coupon Redeem | Cash register ding |

---

## 11. TECHNICAL REQUIREMENTS

### Minimum Specifications
- **iOS:** 14.0+
- **Orientation:** Portrait only
- **Screen:** Optimized for iPhone (various sizes)
- **Download Size:** <50MB
- **Memory:** <200MB runtime

### Performance Targets
- **Frame Rate:** 60 FPS stable
- **Load Time:** <3 seconds
- **Touch Response:** <50ms input lag

### Save System
- **Local Storage:** Coins earned, vehicle unlocks
- **No Cloud Save:** (optional future)
- **Privacy:** No personal data collected

---

## 12. PHASED DEVELOPMENT

### Phase 1: Core Prototype (Week 1-2)
- [ ] Basic runner mechanics (jump, slide)
- [ ] 3 obstacle types
- [ ] Coin collection
- [ ] Game Over screen
- [ ] Test on simulator

### Phase 2: Content Polish (Week 3-4)
- [ ] All 6 obstacle types
- [ ] All 4 power-ups
- [ ] Vehicle unlock system
- [ ] HUD polish

### Phase 3: Audio & Animation (Week 5)
- [ ] Music implementation
- [ ] All SFX
- [ ] Pete animations (idle, run, jump, slide, hit)
- [ ] Particle effects

### Phase 4: Launch Prep (Week 6)
- [ ] Coupon system integration
- [ ] App Store metadata
- [ ] TestFlight build
- [ ] Client review
- [ ] Final launch

---

## 13. SUCCESS METRICS

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Rating | 4.5+ stars | App Store |
| Daily Active Users | 500+ | Analytics |
| Coupon Redemption | 15-25% | Coupon tracking |
| Service Attribution | Trackable | Code redemption |
| Session Length | 2-3 min | Average run time |
| Day 7 Retention | 20%+ | User retention |

---

## 14. RISKS & MITIGATIONS

| Risk | Impact | Mitigation |
|------|--------|------------|
| Asset creation delay | High | Use placeholder art first |
| App Store rejection | Medium | Follow guidelines closely |
| Low engagement | Medium | Add daily challenges, events |
| Technical performance | Medium | Optimize early, test on device |

---

## 15. APPENDIX

### HVAC Tips (Star Collection)
1. "Change air filter every 3 months for better efficiency!"
2. "Well-maintained AC lasts 15-20 years."
3. "Set thermostat to 78°F for optimal cooling."
4. "Clean outdoor units regularly for best performance."
5. "Seal ducts to prevent 30% energy loss!"
6. "Schedule annual tune-ups for peak efficiency."
7. "Use ceiling fans to complement AC cooling."
8. "Close blinds during hottest part of day."

### Color Palette
| Color | Hex | Use |
|-------|-----|-----|
| Pure Red | #E31837 | Brand accents |
| Deep Blue | #1E3A8A | UI, vest |
| Gold | #FFD700 | Coins |
| Star Blue | #00BFFF | Stars |
| Ice Blue | #87CEEB | Power-ups |

---

**Document Version:** 1.0  
**Last Updated:** April 2026  
**Prepared For:** Pure Heating and Air (Digital Kingsmen client)
