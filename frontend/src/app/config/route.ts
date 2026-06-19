import { NextResponse } from 'next/server'

/**
 * Runtime Configuration Endpoint
 *
 * This endpoint provides server-side environment variables to the client at runtime.
 * This solves the NEXT_PUBLIC_* limitation where variables are baked into the build.
 *
 * Environment Variables:
 * - API_URL: Where the browser/client should make API requests (public/external URL)
 * - INTERNAL_API_URL: Where Next.js server-side should proxy API requests (internal URL)
 *   Default: http://localhost:25055 (used by Next.js rewrites in next.config.ts)
 *
 * Why two different variables?
 * - API_URL: Used by browser clients. Set this ONLY if you want the browser to call
 *   the API host:port directly (e.g. https://api.your-domain.com).
 * - INTERNAL_API_URL: Used by Next.js rewrites for server-side proxying, typically
 *   http://localhost:25055.
 *
 * Resolution logic for the browser apiUrl:
 * 1. If API_URL (or NEXT_PUBLIC_API_URL) env var is set, use it (explicit override).
 * 2. Otherwise return an empty string so the browser uses a relative path (/api/*)
 *    on the same origin, which Next.js rewrites proxy server-side to the API.
 *
 * The same-origin proxy is the default because it keeps everything on a single
 * public port (the frontend's). The browser never makes a cross-origin request and
 * the API port does not need to be reachable from the browser — avoiding both
 * CORS issues and the need to expose the API port through firewalls/proxies.
 */
export async function GET() {
  // Priority 1: Check if API_URL is explicitly set (direct browser -> API access)
  const envApiUrl = process.env.API_URL || process.env.NEXT_PUBLIC_API_URL

  if (envApiUrl) {
    return NextResponse.json({
      apiUrl: envApiUrl,
    })
  }

  // Default: empty apiUrl -> client uses relative /api/* on the same origin,
  // which Next.js rewrites proxy to INTERNAL_API_URL (default localhost:25055).
  console.log('[runtime-config] No API_URL set — using same-origin proxy (/api/*)')
  return NextResponse.json({
    apiUrl: '',
  })
}
