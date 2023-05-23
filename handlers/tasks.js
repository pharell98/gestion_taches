const { db } = require("../util/admin");

exports.books = async (req, res) => {
    const tasksRef = db.collection('tasks');
    try{
            tasksRef.get().then((snapshot) => {
            const data = snapshot.docs.map((doc) => ({
            id : doc.id,
            ...doc.data(),
        })) ;
            console.log(données);
            return res.status(201).json(data);
        })
    } catch (error) {
        return res
        .status(500)
        .json({ general : "Quelque chose s'est mal passé, veuillez réessayer"});
    }
} ;