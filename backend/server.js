import express from 'express'
import cors from "cors"
const app = express();


app.use(cors());
app.use(express.json());


app.get("/",(req,res)=>{
    
       res.status(200).json({
        status: "Backend Is Running"
    });
})

app.get("/health", (req, res) => {
    res.status(200).json({
        status: "healthy"
    });
});

app.get("/api/hello", (req, res) => {
    res.json({
        message: "Hello from Rivermark backend"
    });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Backend running on port ${PORT}`);
});