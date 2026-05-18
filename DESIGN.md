---
name: Endurance Performance System
colors:
  surface: '#10141a'
  surface-dim: '#10141a'
  surface-bright: '#353940'
  surface-container-lowest: '#0a0e14'
  surface-container-low: '#181c22'
  surface-container: '#1c2026'
  surface-container-high: '#262a31'
  surface-container-highest: '#31353c'
  on-surface: '#dfe2eb'
  on-surface-variant: '#c1c6d7'
  inverse-surface: '#dfe2eb'
  inverse-on-surface: '#2d3137'
  outline: '#8b90a0'
  outline-variant: '#414755'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e69'
  primary-container: '#4b8eff'
  on-primary-container: '#00285c'
  inverse-primary: '#005bc1'
  secondary: '#bdf4ff'
  on-secondary: '#00363d'
  secondary-container: '#00e3fd'
  on-secondary-container: '#00616d'
  tertiary: '#c2c1ff'
  on-tertiary: '#1c0b9f'
  tertiary-container: '#8382ff'
  on-tertiary-container: '#150093'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#9cf0ff'
  secondary-fixed-dim: '#00daf3'
  on-secondary-fixed: '#001f24'
  on-secondary-fixed-variant: '#004f58'
  tertiary-fixed: '#e2dfff'
  tertiary-fixed-dim: '#c2c1ff'
  on-tertiary-fixed: '#0c006a'
  on-tertiary-fixed-variant: '#3631b4'
  background: '#10141a'
  on-background: '#dfe2eb'
  surface-variant: '#31353c'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  metric-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin-mobile: 16px
  container-margin-desktop: 48px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  section-gap: 40px
---

## Brand & Style

This design system focuses on the steady state of endurance—momentum, flow, and clarity. It avoids the high-intensity "shouting" typical of HIIT or bodybuilding apps, opting instead for a "Zen-Performance" aesthetic. The interface is optimized for high-glanceability during movement (running or cycling), utilizing generous whitespace and a sophisticated "Modern Corporate" foundation blended with "Glassmorphism" to suggest speed and light.

The emotional goal is to feel like a premium cycling computer or a high-end GPS watch: technical and precise, yet inviting enough for daily use. It emphasizes a "Flow State" through smooth transitions and a calm, deep-sea background that reduces eye strain during outdoor or early-morning sessions.

## Colors

The palette is anchored by **Deep Navy (#0A0E14)**, which provides a more sophisticated and less abrasive base than pure black. This depth allows the accent colors to pop without vibrating.

- **Velocity Blue (#007AFF):** Used for primary actions, active route paths, and key progress indicators.
- **Endurance Cyan (#00E5FF):** Used for secondary metrics (e.g., cadence, elevation gain) and interactive elements that require high visibility.
- **Surface Strategy:** We use a "tiered navy" approach. Surfaces closer to the user are lighter and more desaturated blue, creating a sense of natural depth without relying on traditional shadows.
- **Gradients:** Use subtle linear gradients (Velocity Blue to Endurance Cyan) specifically for "Active State" or "Session in Progress" headers to evoke a sense of motion.

## Typography

The choice of **Plus Jakarta Sans** provides a modern, geometric clarity that remains friendly. 

- **Weight Strategy:** Avoid "Extra Bold" or "Black" weights to keep the interface light. Use "SemiBold" (600) for headers to maintain a professional, athletic look.
- **Data Display:** For real-time metrics (pace, heart rate), use the `metric-xl` style. These should always be high-contrast (White or Endurance Cyan) against the Deep Navy background.
- **Readability:** Body text is set with a generous line height (1.5x) and a "Regular" (400) weight to ensure legibility when the user’s device might be vibrating during a ride or run.

## Layout & Spacing

This design system utilizes an **8px base unit** to ensure a consistent rhythmic scale. 

- **Mobile First:** A 4-column grid with 16px margins is the standard. Touch targets for endurance athletes must be generous (minimum 48px height) as fine motor skills decrease during high-exertion activity.
- **Desktop/Tablet:** A 12-column fluid grid with a maximum content width of 1280px. 
- **The "Flow" Layout:** Content should feel unconstrained. Use horizontal scrolling carousels for activity summaries and "Data Tiles" for workout metrics to maximize vertical space.
- **Padding:** Use `stack-lg` (24px) for internal card padding to allow the data "room to breathe."

## Elevation & Depth

Visual hierarchy is established through **Tonal Layering** and **Glassmorphism**, avoiding heavy drop shadows which can feel dated or "heavy."

- **Glassmorphism:** Use for persistent navigation bars and "Live Activity" overlays. A 20px background blur with a 10% white border-stroke mimics the look of high-end sports eyewear.
- **Z-Axis:** 
  - **Level 0 (Background):** Deep Navy (#0A0E14).
  - **Level 1 (Cards):** Surface-1 (#141A23) with no shadow.
  - **Level 2 (Active/Selected):** Surface-2 (#1C252F) with a subtle, diffused Velocity Blue glow (0px 4px 20px, 15% opacity).
- **Outlines:** Use 1px "Ghost Borders" (#FFFFFF at 10% opacity) to define shapes without creating visual noise.

## Shapes

In alignment with **ROUND_EIGHT**, we use a `0.5rem` (8px) base radius for standard elements, scaling up for larger containers.

- **Standard Components:** Buttons, Input Fields, and Small Cards use 8px corners.
- **Container Level:** Large Dashboard Cards and Modals use `rounded-xl` (1.5rem / 24px) to feel soft and approachable.
- **Pills:** Full-round (999px) is reserved exclusively for status badges (e.g., "Active," "Completed") and primary CTA buttons to distinguish them from informational cards.

## Components

- **Buttons:** Primary buttons use a Velocity Blue to Endurance Cyan gradient with white text. Secondary buttons use the "Ghost" style: 1px Endurance Cyan border with no fill.
- **Metrics Tiles:** Square or rectangular cards with a `label-md` category at the top and a `metric-xl` value in the center. Use a subtle trend sparkline (Velocity Blue) in the background.
- **Progress Rings:** Use thin, 4px strokes. The background track should be `surface-3`, and the active track should be a gradient.
- **Lists:** Activity history lists should use high-contrast text for titles and low-contrast `body-md` for secondary metadata (date/time).
- **Navigation:** A bottom tab bar using glassmorphism. Icons should be "Light" weight (1.5px stroke) to match the clean typography.
- **Interactive Graphs:** Use "Endurance Cyan" for the primary data line with a soft blue area fill (10% opacity) underneath to visualize volume and effort.