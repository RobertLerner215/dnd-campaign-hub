# Accessibility Statement

## Our Commitment

We are committed to creating a website that is accessible and usable for all visitors, including users with disabilities. Accessibility is an ongoing priority in the design and development of this application. Our goal is to ensure all users can navigate pages, complete forms, and access information regardless of ability or assistive technology.

---

## Accessibility Concern 1: Semantic Headings

Using proper heading structure helps screen readers understand the layout of a page and allows users to move between sections efficiently.

### Description

Pages use headings such as titles and section headers to organize information clearly.

### Code Sample

```heex
<.header>
  Listing Pages
</.header>
```

### Example From Project

```heex
<.header>
  Listing Pages
  <:actions>
    <.link navigate={~p"/pages/new"} class="button">
      New Page
    </.link>
  </:actions>
</.header>
```

Found in `lib/app_web/live/page_live/index.ex`.

---

## Accessibility Concern 2: Keyboard Navigation

Users who cannot use a mouse should still be able to navigate using only a keyboard.

### Description

Links, buttons, and form controls can all be reached with the Tab key, which helps users who rely on keyboards instead of a mouse.

### Code Sample

```heex
<.link navigate={~p"/pages/new"} class="button">
  New Page
</.link>
```

### Example From Project

```heex
<.link href={~p"/accessibility"} class="text-blue-300 hover:underline">
  Accessibility
</.link>
```

Found in `lib/app_web/components/ui/navbar.ex`.

---

## Accessibility Concern 3: Form Labels

Every form field should include a visible label so users know what information is required.

### Description

Labels make forms easier to understand for all users and help screen readers announce the purpose of each field.

### Code Sample

```html
<label for="user_name">Name</label>
<input type="text" name="user[name]" id="user_name">
```

### Example From Project

```heex
<.input field={@form[:content]} type="textarea" label="Content" />
```

Found in `lib/app_web/live/page_live/form.ex`.

---

## Accessibility Concern 4: Color Contrast

Text should have strong contrast against the background so content is easy to read.

### Description

Dark backgrounds with light text improve readability and help users with low vision distinguish content more clearly.

### Code Sample

```heex
<nav class="bg-slate-800 text-white border-b border-slate-600">
```

### Example From Project

```heex
<nav class="bg-slate-800 border-b border-slate-600 px-6 py-4 flex justify-between items-center">
```

Found in `lib/app_web/components/ui/navbar.ex`.

---

## Accessibility Concern 5: Responsive Design

Pages should work on desktop, tablet, and mobile screens.

### Description

Flexible layouts help users access the site across many screen sizes without losing readability or structure.

### Code Sample

```heex
<div class="mx-auto max-w-5xl px-8 py-10">
```

### Example From Project

```heex
<div class="max-w-5xl mx-auto px-8 py-10 text-white">
  <div class="bg-slate-900 rounded-2xl shadow-xl p-10">
    {Phoenix.HTML.raw(@content)}
  </div>
</div>
```

Found in `lib/app_web/live/accessibility_live.ex`.

---

## Accessibility Concern 6: Consistent Navigation

Navigation should stay in the same location across pages.

### Description

Users can predict where important links are located because the same layout and navbar are used throughout the application.

### Code Sample

```heex
<Layouts.app flash={@flash} current_scope={@current_scope}>
  ...
</Layouts.app>
```

### Example From Project

```heex
<Layouts.app flash={@flash} current_scope={@current_scope}>
  <.header>
    Listing Pages
  </.header>
</Layouts.app>
```

Used across multiple LiveViews such as `page_live/index.ex`, `page_live/show.ex`, `page_live/form.ex`, and `accessibility_live.ex`.

---

## Accessibility Concern 7: Readable Content

Readable font sizes, spacing, and organization help all users.

### Description

Large headings, spacing between sections, and a clear page layout improve comprehension and reduce visual clutter.

### Code Sample

```heex
<h1 class="text-5xl font-bold mb-8">
  Accessibility Statement
</h1>
```

### Example From Project

```heex
<article class="space-y-6 [&_h1]:text-5xl [&_h1]:font-bold [&_h2]:text-3xl">
  {Phoenix.HTML.raw(@content)}
</article>
```

Found in `lib/app_web/live/accessibility_live.ex`.

---

## Ongoing Improvements

We will continue testing and improving accessibility using keyboard testing, user feedback, and accessibility evaluation tools. Future improvements may include stronger focus indicators, more screen reader testing, and additional checks for responsive behavior.

---

## Contact

If you experience an accessibility issue while using this site, please contact the site administrator.
