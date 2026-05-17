import {RequestHandler} from "express";
import supabase from "../database/supabaseClient"

type GetFoodsReqQuery = {
    page?: string,
    pageSize?: string
    conditions?: string
}

const getFoods : RequestHandler<unknown, unknown, unknown, GetFoodsReqQuery> = async (req, res) => {
    const query = supabase.from('ingredient').select('*');
    const page = parseInt(req.query.page || "")
    if (page) {
        // Paginated
        const pageSize = parseInt(req.query.pageSize || "")
        if (page <= 0 || pageSize <= 0 || pageSize > 200) {
            return res.status(400).json({reason: "Pagination out of range (note: pagination is 1 based indexing, size limit is 200)", page: {page, pageSize}})
        }
        const startingPoint = pageSize * (page - 1)
        query.range(startingPoint, startingPoint + pageSize - 1);
    }
    const conditions = JSON.parse(req.query.conditions || "")
    if (conditions) {
        for (const [column, value] of Object.entries(conditions)) {
            query.eq(column, value)
        }
    }
    try {
        const {data, error} = await query;
        if (error) {
            console.log(error)
            return res.status(500).send({reason: "DB error"})
        }
        return res.json(data)
    }
    catch (error) {
        console.log(error)
        return res.status(500).send({reason: "Request error"})
    }
}

type GetFoodsByIdReqParam = {
    id: string,
}

const getFoodsById : RequestHandler<GetFoodsByIdReqParam, unknown, unknown, unknown> = async (req, res) => {
    const id = parseInt(req.params.id);
    if (!id) {
        return res.status(400).json({reason: "ID is NaN, invalid or missing"})
    }
    const query = supabase.from('ingredient').select('*').eq("id", id).limit(1).single();
    try {
        const {data, error} = await query;
        if (error) {
            console.log(error)
            return res.status(500).send({reason: "DB error"})
        }
        return res.json(data)
    }
    catch (error) {
        console.log(error)
        return res.status(500).send({reason: "Request error"})
    }
}

type PostFoodsReqBody = {
    name: string,
    calorie_count: number,
}

const postFood : RequestHandler<unknown, unknown, PostFoodsReqBody, unknown> = async (req, res) => {
    const body = req.body;
    const query = supabase.from('ingredient').insert(body);
    try {
        const {data, error} = await query;
        if (error) {
            console.log(error)
            return res.status(500).send({reason: "DB error"})
        }
        return res.sendStatus(200)
    }
    catch (error) {
        console.log(error)
        return res.status(500).send({reason: "Request error"})
    }
}

export default {
    getFoods,
    getFoodsById,
    postFood
}
