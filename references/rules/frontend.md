# Frontend rules

Rules for repos with a UI. Format and usage: [README.md](README.md).

## Caught error messages are not shown verbatim

- **Problem:** the client shows `err.message` from a failed call or thrown exception (`toast(err.message)`, `setError(err.message)`), so users see technical text.
- **Applies when:** the UI shows errors in toasts, banners or form errors.
- **Check:**
  - Preferred: the server-side rule in [backend.md](backend.md) "Raw error messages never reach the client", so the API only returns user-ready messages and the client shows those. If the client shows API error text in one place (a shared fetch wrapper), this side alone is enough.
  - Optional: a lint rule (ESLint `no-restricted-syntax`) banning `err.message` as an argument of the toast / error-setter functions. More false positives than the server side; exempt messages the app itself builds.
- **False positives:** errors constructed by the app with a user message on purpose.

## Text sizes scale with the user's font setting
- **Problem:** hard-coded pixel font sizes ignore the user's font-size preference and browser zoom settings.
- **Applies when:** the app offers a font-size preference or targets accessibility.
- **Check:** conformance test scanning components for pixel text sizes (e.g. Tailwind `text-[13px]`); rem only.

## Heavy client libraries load lazily
- **Problem:** charting/media SDKs land in the initial bundle of every page that imports them.
- **Applies when:** the app uses big client-only libs.
- **Check:** conformance test: listed heavy packages are imported only through the framework's lazy loader (`next/dynamic`, `React.lazy`).

## Forms declare their method
- **Problem:** a `<form>` without `method` falls back to GET before hydration and puts field values (passwords) in the URL.
- **Applies when:** the UI renders HTML forms server-side.
- **Check:** lint `no-restricted-syntax` on `<form>` without `method`, plus a test that every override block keeps it.
