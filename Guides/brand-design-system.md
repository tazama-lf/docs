<!-- SPDX-License-Identifier: Apache-2.0 -->

# Brand Design System <!-- omit in toc -->

<a id="top"></a>

A reference guide for the Tazama visual identity, extracted from [tazama.org](https://www.tazama.org/). Use these tokens to ensure consistent branding across documentation, presentations, and project assets.

## Table of Contents <!-- omit in toc -->

- [1. Logo](#1-logo)
  - [1.1. Primary Logo](#11-primary-logo)
  - [1.2. Icon Mark](#12-icon-mark)
  - [1.3. Logo Colors](#13-logo-colors)
- [2. Color Palette](#2-color-palette)
  - [2.1. Brand Core](#21-brand-core)
  - [2.2. Teal / Green Tints](#22-teal--green-tints)
  - [2.3. Neutrals](#23-neutrals)
  - [2.4. Semantic / Status](#24-semantic--status)
- [3. Typography](#3-typography)
  - [3.1. Typeface](#31-typeface)
  - [3.2. Type Scale](#32-type-scale)
  - [3.3. Font Weights](#33-font-weights)
- [4. Buttons](#4-buttons)
- [5. Spacing](#5-spacing)
- [6. Border Radius](#6-border-radius)
- [7. Shadows](#7-shadows)
- [8. Layout and Containers](#8-layout-and-containers)
- [9. CSS Custom Properties Reference](#9-css-custom-properties-reference)
- [10. Technical Notes](#10-technical-notes)

---

## 1. Logo

### 1.1. Primary Logo

The Tazama logo consists of two elements:

- **Wordmark** ("Tazama") in Deep Green `#003C30`
- **Icon** (five-petal/star motif with dots) in Teal `#51BE99`

The primary logo SVG file is located at:
`/wp-content/uploads/sites/22/2025/02/Tazama_Primary.svg`

**Usage guidelines:**

| Background | Wordmark Color | Icon Color |
|---|---|---|
| Light / White | Deep Green `#003C30` | Teal `#51BE99` |
| Dark / Deep Green | White `#FFFFFF` | Teal `#51BE99` |

### 1.2. Icon Mark

The icon mark (star motif without the wordmark) can be used independently where space is limited. It always uses Teal `#51BE99` regardless of background color.

### 1.3. Logo Colors

The SVG logo uses two CSS classes from the original Adobe Illustrator export:

- `.st0` / `.st2` — `fill: #003C30` (wordmark)
- `.st1` — `fill: #51BE99` (icon)

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 2. Color Palette

### 2.1. Brand Core

| Color | Hex | Usage |
|---|---|---|
| **Deep Green** | `#003C30` | Primary brand, headings, body text, footer background, logo wordmark |
| **Teal** | `#51BE99` | Logo icon, secondary buttons, accents, links |
| **Orange** | `#F57E20` | Primary CTA buttons, highlights, attention |

### 2.2. Teal / Green Tints

These tints are used as section backgrounds to create visual rhythm across the site.

| Name | Hex |
|---|---|
| Deep Green | `#003C30` |
| Teal | `#51BE99` |
| Teal Light 1 | `#8AD3BB` |
| Teal Light 2 | `#AFE1D0` |
| Teal Light 3 | `#C9EBDF` |
| Gray Green | `#E6ECEA` |
| Off White | `#F1F1F1` |
| White | `#FFFFFF` |

### 2.3. Neutrals

| Hex | Name |
|---|---|
| `#000000` | Black |
| `#2D2D2D` | Gray 800 |
| `#333333` | Gray 700 |
| `#4B4F52` | Gray 600 |
| `#606060` | Gray 500 |
| `#888888` | Gray 400 |
| `#A0A0A0` | Gray 300 |
| `#CCCCCC` | Gray 200 |
| `#EEEEEE` | Gray 100 |
| `#F1F1F1` | Off White |
| `#FFFFFF` | White |

### 2.4. Semantic / Status

| Color | Hex | Usage |
|---|---|---|
| **Error / Alert** | `#FF1053` | Error states, alerts |
| **Dark Gray (WP)** | `#32373C` | WordPress default buttons |

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 3. Typography

### 3.1. Typeface

- **Primary typeface:** Open Sans ([Google Fonts](https://fonts.google.com/specimen/Open+Sans))
- **Font stack:** `'Open Sans', system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`
- **Weights loaded:** 300 (Light), 400 (Regular), 600 (Semibold), 700 (Bold)

### 3.2. Type Scale

| Size | Line Height | Weight | Usage |
|---|---|---|---|
| 48px | 56px | 700 | Display / Brand name |
| 43px | 48px | 700 | Hero heading |
| 41px | 48px | 600 | Section title |
| 36px | 42px | 600 | Large heading |
| 34px | 40px | 600 | Subheading |
| 32px | 39px | 600 | Feature title |
| 29px | 36px | 600 | Card heading |
| 27px | 33px | 600 | Component title |
| 24px | 31px | 600 | Small heading |
| 22px | 29px | 600 | Widget title |
| 21px | 29px | 400 | Lead text / Introductions |
| 20px | 29px | 400 | Medium body (wide sections) |
| 18px | 24px | 400 | Standard body text |
| 16px | 22px | 400 | Default body text (base) |
| 14px | 19px | 400 | Small body / Captions |
| 13px | 17px | 400 | Fine print / Labels / Metadata |
| 10px | 13px | 400 | Micro labels and badges (uppercase, 1px letter-spacing) |

### 3.3. Font Weights

| Weight | Name |
|---|---|
| 300 | Light |
| 400 | Regular |
| 500 | Medium |
| 600 | Semibold |
| 700 | Bold |

**Letter spacing:**

- Body text: `0` (normal)
- Uppercase labels and tags: `1px` with `text-transform: uppercase` and weight 700

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 4. Buttons

All buttons use a **pill shape** (`border-radius: 200px`) and `font-weight: 700`. The Salient theme applies `data-button-style="rounded"`.

| Variant | Background | Text | Hover | Radius |
|---|---|---|---|---|
| **Primary CTA** | `#F57E20` | `#000000` | text changes to `#FFFFFF` | 200px (pill) |
| **Secondary** | `#51BE99` | `#003C30` | text changes to `#FFFFFF` | 200px (pill) |
| **Dark** | `#003C30` | `#FFFFFF` | bg changes to `#002A21` | 200px (pill) |
| **Outline** | transparent | `#003C30` | bg changes to `#003C30`, text changes to `#FFFFFF` | 200px (pill) |

**Button padding:** `14px 32px` (outline uses `12px 30px` to account for the 2px border).

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 5. Spacing

WordPress preset spacing scale used across the site:

| Token | rem | px (approx.) |
|---|---|---|
| 20 | 0.44rem | ~7px |
| 30 | 0.67rem | ~11px |
| 40 | 1rem | 16px |
| 50 | 1.5rem | 24px |
| 60 | 2.25rem | 36px |
| 70 | 3.38rem | ~54px |
| 80 | 5.06rem | ~81px |

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 6. Border Radius

| Token | Value | Usage |
|---|---|---|
| sm | `2px` | Subtle rounding |
| md (nectar) | `15px` | Cards, sections |
| lg (nectar) | `20px` | Large cards |
| pill | `100px` | Tags, badges |
| pill (buttons) | `200px` | Buttons |

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 7. Shadows

Shadows are tinted with brand colors (`#003C30` and `#51BE99`) rather than pure black for a more cohesive feel.

| Name | Value |
|---|---|
| Subtle | `1px 2px 3px rgba(0, 0, 0, 0.16)` |
| Card | `0 3px 45px rgba(0, 0, 0, 0.15)` |
| Button (green) | `0px 8px 15px rgba(0, 60, 48, 0.3)` |
| Button (teal) | `0px 8px 15px rgba(81, 190, 153, 0.4)` |
| Large elevation | `0 30px 90px rgba(0, 60, 48, 0.2)` |

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 8. Layout and Containers

| Token | Value | Usage |
|---|---|---|
| `content-size` | `1300px` | Max content width |
| `wide-size` | `1300px` | Wide alignment |
| `header-height` | ~70px | Sticky header height (desktop) |
| `header-height-mobile` | ~63px | Mobile header height |
| `header-breakpoint` | `1250px` | Mobile nav breakpoint |
| `column-padding` | `2%` | Responsive column padding |

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 9. CSS Custom Properties Reference

```css
/* Brand Core */
--deep-green:     #003C30;  /* primary, text, footer */
--teal:           #51BE99;  /* logo icon, secondary */
--orange:         #F57E20;  /* CTAs, highlights */

/* Section Background Tints */
--teal-light-1:   #8AD3BB;
--teal-light-2:   #AFE1D0;
--teal-light-3:   #C9EBDF;
--gray-green:     #E6ECEA;

/* Neutrals */
--gray-700:       #333333;
--gray-500:       #606060;
--gray-400:       #888888;
--gray-200:       #CCCCCC;
--off-white:      #F1F1F1;

/* Typography */
--font-sans: 'Open Sans', system-ui, sans-serif;

/* Border Radius */
--radius-md:    15px;   /* cards, sections */
--radius-lg:    20px;   /* large cards */
--radius-pill:  200px;  /* buttons */

/* Content */
--content-width: 1300px;
```

<div style="text-align: right"><a href="#top">Top</a></div>

---

## 10. Technical Notes

| Component | Detail |
|---|---|
| **Platform** | WordPress 6.9 |
| **Theme** | Salient (ThemeNectar) v18.0.2 + Child Theme |
| **Page Builder** | WPBakery (Visual Composer) |
| **Icons** | Font Awesome 6.0 |
| **Font** | Open Sans via Google Fonts (300, 400, 600, 700) |
| **Logo source** | Adobe Illustrator 29.2.1, exported as SVG |
| **Logo classes** | `.st0 { fill: #003c30 }` (wordmark), `.st1 { fill: #51be99 }` (icon) |

<div style="text-align: right"><a href="#top">Top</a></div>
