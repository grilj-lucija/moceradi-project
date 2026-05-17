import {Request, Response} from "express";

export default {
    test: async (req: Request, res: Response) => {
        if (req.body) {
            res.json(req.body);
        }
        return res.json({response: "OK"})
    }
}