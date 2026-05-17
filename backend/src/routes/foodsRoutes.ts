import express from "express";
import foodsController from "../controllers/foodsController";

const router = express.Router();

router.get("/", async (req, res) => {
    await foodsController.getFoods(req, res)
})

router.get("/:id", async (req, res) => {
    //TODO
    res.sendStatus(404)
})

router.post("/", async (req, res) => {
    //TODO
    res.sendStatus(404)
})

export default router;