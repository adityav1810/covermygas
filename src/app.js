//Imports
const express = require('express')
const app = express()
const port = 3000

//Static Files
app.use(express.static('public'))
app.use('/css',express.static(__dirname+'public/css'))
app.use('/js',express.static(__dirname+'public/js'))
app.use('/img',express.static(__dirname+'public/img'))

//Set Views
app.set('views','./views')
app.set('view engine','ejs')

app.get('',(req,res)=>{
    res.render('home')
})
app.get('/home',(req,res)=>{
    res.render('home')
})


app.get('/about',(req,res)=>{
    res.render('about')
})
app.get('/team',(req,res)=>{
    res.render('team')
})
app.get('/buy',(req,res)=>{
    res.render('buy')
})
app.get('/sell',(req,res)=>{
    res.render('sell')
})

app.listen(port,()=>console.info(`Listening on port ${port}`))