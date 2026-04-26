const supabaseUrl = "https://ydogahzvieaunitxaoim.supabase.co";
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlkb2dhaHp2aWVhdW5pdHhhb2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMzQwOTksImV4cCI6MjA5MjgxMDA5OX0.l4ZlXqeASYruZ1dZ7ZZ3QRAxFlBl6vrzU_SYYH8-eiQ";

window.supabaseClient = supabase.createClient(supabaseUrl, supabaseKey, {
  auth: {
    storage: window.localStorage,
    storageKey: 'origination-auth-token',
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  }
});