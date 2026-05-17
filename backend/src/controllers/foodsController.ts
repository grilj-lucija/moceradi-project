import {Request, Response} from "express";
import supabase from "../database/supabaseClient"

export default {
    getFoods: async (req: Request, res: Response) => {
        try {
            const  {data, error} = await supabase.from('ingredient').select('*').limit(10);
            if (error) {
                console.log(error)
                return res.status(500).send({})
            }
            return res.json(data)
        }
        catch (error) {
            console.log(error)
            return res.status(500).send({})
        }
    }
}
