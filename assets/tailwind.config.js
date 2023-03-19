// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  safelist: ["text-[0.4em]", "text-[0.5em]", "text-[0.6em]", "text-[0.7em]", "text-[0.8em]",
  "text-[0.9em]", "text-[1.0em]", "text-[1.1em]", "text-[1.2em]", "text-[1.3em]",
  "text-[1.4em]", "text-[1.5em]", "text-[1.6em]", "text-[1.7em]", "text-[1.8em]",
  "text-[1.9em]", "text-[2.0em]", "text-[2.1em]", "text-[2.2em]", "text-[2.3em]",
  "text-[2.4em]", "text-[2.5em]", "text-[2.6em]", "text-[2.7em]", "text-[2.8em]",
  "text-[2.9em]", "text-[3.0em]",
  "leading-[1.0em]", "leading-[1.1em]", "leading-[1.2em]", "leading-[1.3em]",
 "leading-[1.4em]", "leading-[1.5em]", "leading-[1.6em]", "leading-[1.7em]",
 "leading-[1.8em]", "leading-[1.9em]", "leading-[2.0em]", "leading-[2.1em]",
 "leading-[2.2em]", "leading-[2.3em]", "leading-[2.4em]", "leading-[2.5em]",
 "leading-[2.6em]", "leading-[2.7em]", "leading-[2.8em]", "leading-[2.9em]",
 "leading-[3.0em]"],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
