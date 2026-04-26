const supabaseUrl = "https://dzpdcfmlavcnhwmjjmbf.supabase.co";
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cGRjZm1sYXZjbmh3bWpqbWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2OTQ1NzcsImV4cCI6MjA2MTI3MDU3N30.sDkdIiUQY0S2kNVoVwbUMg_f_zTObmk";

window.supabaseClient = supabase.createClient(supabaseUrl, supabaseKey, {
  auth: {
    storage: window.localStorage,
    storageKey: 'origination-auth-token',
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  }
});