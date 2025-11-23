# 🎨 Tailwind CSS 4 + shadcn/ui Setup Guide

## ✅ What's Installed

- **Tailwind CSS 4.1.16** - Latest version with new @theme syntax
- **tailwindcss-rails** - Rails integration for Tailwind
- **shadcn/ui** - Pre-configured for component usage
- **Righteous Font** - Already integrated for branding

## 📁 File Structure

```
app/
├── assets/
│   ├── builds/
│   │   └── tailwind.css          # Compiled Tailwind CSS
│   └── tailwind/
│       └── application.css        # Tailwind source with @theme
├── components/
│   └── ui/                        # shadcn/ui components go here
├── javascript/
│   └── lib/
│       └── utils.js               # Helper functions
└── views/
    └── layouts/
        └── application.html.erb   # Includes Tailwind CSS

components.json                     # shadcn/ui configuration
Procfile.dev                       # Development process file
```

## 🚀 Usage

### Starting the App

**With auto-rebuild (recommended):**
```bash
bin/dev
```

This starts both:
- Rails server (port 3000)
- Tailwind CSS watcher (auto-rebuilds on changes)

**Manual mode:**
```bash
# Terminal 1: Start Rails
bin/rails server

# Terminal 2: Watch Tailwind changes
rails tailwindcss:watch

# Or build once
rails tailwindcss:build
```

### Using Tailwind Classes

All standard Tailwind CSS 4 classes work:

```erb
<div class="bg-blue-500 text-white p-4 rounded-lg">
  Hello Tailwind!
</div>
```

### Custom Theme Variables

The theme is configured in `app/assets/tailwind/application.css`:

```css
@theme {
  --font-family-righteous: "Righteous", sans-serif;

  /* shadcn/ui colors */
  --color-primary: 221.2 83.2% 53.3%;
  --color-destructive: 0 84.2% 60.2%;
  --radius: 0.5rem;
}
```

**Using theme colors:**
```erb
<button class="bg-primary text-primary-foreground px-4 py-2 rounded">
  Click me
</button>
```

## 📦 Adding shadcn/ui Components

### Using the MCP Tools

You can search and add shadcn components directly:

```ruby
# In Rails console or via Claude
# Search for a component
mcp__shadcn__search_items_in_registries(
  registries: ['@shadcn'],
  query: 'button'
)

# View component details
mcp__shadcn__view_items_in_registries(
  items: ['@shadcn/button']
)

# Get the add command
mcp__shadcn__get_add_command_for_items(
  items: ['@shadcn/button']
)
```

### Manual Installation

For Rails, you'll adapt the components to ERB. Example button component:

**app/components/ui/button_component.rb**
```ruby
class Ui::ButtonComponent < ViewComponent::Base
  attr_reader :variant, :size

  def initialize(variant: 'default', size: 'default', **options)
    @variant = variant
    @size = size
    @options = options
  end

  def call
    content_tag :button, content, **html_options
  end

  private

  def html_options
    {
      class: button_classes,
      **@options
    }
  end

  def button_classes
    base = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors"
    variants = {
      'default' => 'bg-primary text-primary-foreground hover:bg-primary/90',
      'destructive' => 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      'outline' => 'border border-input bg-background hover:bg-accent',
      'ghost' => 'hover:bg-accent hover:text-accent-foreground'
    }
    sizes = {
      'default' => 'h-10 px-4 py-2',
      'sm' => 'h-9 px-3',
      'lg' => 'h-11 px-8'
    }

    [base, variants[@variant], sizes[@size]].join(' ')
  end
end
```

**Usage in views:**
```erb
<%= render Ui::ButtonComponent.new do %>
  Click me
<% end %>

<%= render Ui::ButtonComponent.new(variant: 'destructive', size: 'lg') do %>
  Delete
<% end %>
```

### Simpler Approach (Helpers)

**app/helpers/ui_helper.rb**
```ruby
module UiHelper
  def ui_button(text, variant: 'default', size: 'default', **options)
    classes = button_classes(variant, size)
    options[:class] = [options[:class], classes].compact.join(' ')

    button_tag(text, **options)
  end

  private

  def button_classes(variant, size)
    base = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors"
    variants = {
      'default' => 'bg-primary text-primary-foreground hover:bg-primary/90',
      'destructive' => 'bg-destructive text-destructive-foreground hover:bg-destructive/90'
    }
    sizes = {
      'default' => 'h-10 px-4 py-2',
      'lg' => 'h-11 px-8'
    }

    [base, variants[variant], sizes[size]].join(' ')
  end
end
```

**Usage:**
```erb
<%= ui_button "Click me", variant: 'default' %>
<%= ui_button "Delete", variant: 'destructive', size: 'lg' %>
```

## 🎨 Custom Styles

### Adding Custom Styles

Edit `app/assets/tailwind/application.css`:

```css
@layer components {
  .btn-fire {
    @apply bg-gradient-to-r from-orange-500 via-red-500 to-pink-500;
    @apply text-white font-bold py-2 px-4 rounded;
    @apply hover:shadow-lg transition-shadow;
  }
}
```

**Usage:**
```erb
<button class="btn-fire">Hot Deal! 🔥</button>
```

### Fire Theme (Custom)

```css
@theme {
  /* Custom fire colors */
  --color-fire-red: 221 100% 40%;
  --color-fire-orange: 22 100% 50%;
  --color-fire-yellow: 45 100% 50%;
}
```

**Usage:**
```erb
<div class="bg-fire-red text-white">
  🔥 Hot procurement!
</div>
```

## 🔧 Configuration

### components.json

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": false,
  "tsx": false,
  "tailwind": {
    "config": "app/assets/tailwind/application.css",
    "css": "app/assets/tailwind/application.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "app/components/ui",
    "utils": "app/javascript/lib/utils"
  },
  "registries": {
    "default": "@shadcn"
  }
}
```

### Tailwind CSS Version

Using **Tailwind CSS 4** with the new `@import` and `@theme` syntax.

**Old (v3):**
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**New (v4):**
```css
@import "tailwindcss";

@theme {
  /* theme variables */
}
```

## 📚 Resources

- **Tailwind CSS 4:** https://tailwindcss.com/
- **shadcn/ui:** https://ui.shadcn.com/
- **shadcn Registry:** Use MCP tools to browse components
- **tailwindcss-rails:** https://github.com/rails/tailwindcss-rails

## 🎯 Quick Examples

### Card Component

```erb
<div class="bg-card text-card-foreground rounded-lg border p-6 shadow-sm">
  <h3 class="text-2xl font-bold mb-2">Procurement Title</h3>
  <p class="text-muted-foreground">Description goes here...</p>

  <div class="mt-4 flex gap-2">
    <button class="bg-primary text-primary-foreground px-4 py-2 rounded-md hover:bg-primary/90">
      View Details
    </button>
    <button class="bg-secondary text-secondary-foreground px-4 py-2 rounded-md hover:bg-secondary/80">
      Star
    </button>
  </div>
</div>
```

### Input with Label

```erb
<div class="space-y-2">
  <label class="text-sm font-medium text-foreground">Search</label>
  <input
    type="text"
    class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
    placeholder="Search procurements..."
  />
</div>
```

### Badge

```erb
<span class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-primary text-primary-foreground hover:bg-primary/80">
  New
</span>
```

## 🐛 Troubleshooting

### Styles not loading?

1. **Check if Tailwind CSS is built:**
   ```bash
   ls app/assets/builds/tailwind.css
   ```

2. **Rebuild manually:**
   ```bash
   rails tailwindcss:build
   ```

3. **Check the layout includes the stylesheet:**
   ```erb
   <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
   ```

### Changes not reflecting?

1. **Use bin/dev for auto-rebuild:**
   ```bash
   bin/dev
   ```

2. **Or manually watch:**
   ```bash
   rails tailwindcss:watch
   ```

### Classes not working?

1. Make sure you're using Tailwind 4 syntax
2. Check `app/assets/tailwind/application.css` for theme config
3. Verify the class exists in Tailwind docs

## ✨ Next Steps

1. **Add ViewComponent** for reusable components:
   ```bash
   bundle add view_component
   ```

2. **Browse shadcn components** using MCP tools

3. **Create custom components** in `app/components/ui/`

4. **Customize theme** in `app/assets/tailwind/application.css`

Your app is now ready to use Tailwind CSS 4 and shadcn/ui! 🎉
