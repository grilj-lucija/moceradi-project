import {createClient} from "@supabase/supabase-js";

function createSupabaseClient() {
    const databaseUrl = process.env.DATABASE_URL;
    const databaseKey = process.env.DATABASE_KEY;
    if (!(databaseKey && databaseUrl)) {
        throw new Error(`Could not find ${!databaseUrl ? "DATABASE_URL" : ""}${!(databaseUrl || databaseKey) ? " and " : ""}${!databaseKey ? "DATABASE_KEY" : ""}`)
    }
    return createClient(databaseUrl, databaseKey)
}

const supabase = createSupabaseClient();

export default supabase