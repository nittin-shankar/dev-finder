// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  darkMode: 'class',
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        // All light mode colors in the Figma file
        "bright-blue": "#0079FF", // This color is used in both light mode and dark mode
        "soft-gray": "#697C9A",
        "soft-bluish-gray": "#4B6A9B",
        "soft-blackish-blue": "#2B3442",
        "very-soft-bluish-gray": "#F6F8FF",
        "near-white": "#FEFEFE",

        // All dark mode colors in the Figma file
        'near-black': "#141D2F",
        'bright-blackish-blue': "#1E2A47"
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"]))
  ]
}