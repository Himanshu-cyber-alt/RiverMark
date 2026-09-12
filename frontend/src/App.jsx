import { useState,useEffect  } from 'react'

import './App.css'

function App() {

      const [message, setMessage] = useState('');


       useEffect(() => {
    fetch('/api/hello')
      .then((res) => res.json())
      .then((data) => setMessage(data.message))
      .catch((err) => console.error('Failed to fetch:', err));
  }, []);



  return (
    <>
  <h1>RiverMark</h1>


  <h2>{message}</h2>
    </>
  )
}

export default App
