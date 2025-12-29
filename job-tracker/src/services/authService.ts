import { createClient } from "@/dbConfig";

export const authService = {
  async signInWithGoogle() {
    const supabase = await createClient();

    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        // This is where Google sends the user after they log in
        redirectTo: `http://localhost:3000/auth/callback`,
      },
    });

    if (error) throw error;
    return data.url; // The frontend will redirect the user to this URL
  },

  async signOut() {
    const supabase = await createClient();
    await supabase.auth.signOut();
  },

  async getCurrentUser() {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    return user;
  },
};
