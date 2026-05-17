import express from "express";
import foodsController from "../controllers/foodsController";

const router = express.Router();

router.get("/", async (req, res, next) => {
    await foodsController.getFoods(req, res, next)
})

router.get("/:id", async (req, res, next) => {
    await foodsController.getFoodsById(req, res, next)
})

router.post("/", async (req, res, next) => {
    await foodsController.postFood(req, res, next)
})

export default router;