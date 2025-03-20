console.log("javascript file loaded");

const firebaseConfig = {
    apiKey: "AIzaSyC6M1WLbJWF5oWOQOnsMH6I-4TpXP4FqmE",
    authDomain: "gigready-dbeaf.firebaseapp.com",
    projectId: "gigready-dbeaf",
    storageBucket: "gigready-dbeaf.firebasestorage.app",
    messagingSenderId: "398144151156",
    appId: "1:398144151156:web:e57213673769091630bb21"
};

const app = firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const database = firebase.database();

const setlistGrid = document.querySelector('.setlist-grid');
const songList = document.querySelector('.song-list');
const songGrid = document.querySelector('.song-grid');
const lyricsDisplay = document.querySelector('.lyrics-display');
const lyricsContent = document.querySelector('.lyrics-content');
const backButton = document.getElementById('backButton');
const songBackButton = document.getElementById('songBackButton');
const addSongButton = document.getElementById('addSongButton');
const songModal = document.getElementById('songModal');
const closeButton = document.querySelector('.close');
const saveSongButton = document.getElementById('saveSongButton');
const songNameInput = document.getElementById('songNameInput');
const songLyricsInput = document.getElementById('songLyricsInput');
const deleteSongButton = document.getElementById('deleteSongButton');
const viewAllSongsButton = document.getElementById('viewAllSongsButton');
const allSongsList = document.querySelector('.all-songs-list');
const allSongGrid = document.querySelector('.all-song-grid');
const allSongsBackButton = document.getElementById('allSongsBackButton');
const addAllSongButton = document.getElementById('addAllSongButton');
const setlistDropdown = document.getElementById('setlistDropdown');
const setlistSelect = document.getElementById('setlistSelect');

let currentSetlist = null;
let viewAll = false;

// Login Functionality
auth.onAuthStateChanged((user) => {
    if (user) {
        // User is signed in, see docs for a list of available properties
        // https://firebase.google.com/docs/reference/js/firebase.User
        const uid = user.uid;
        console.log("User is logged in", uid);
        loadSetlists();
    } else {
        // User is signed out
        console.log("User is logged out");
        // Implement login UI here
        login();
    }
});

function login() {
    auth.signInAnonymously()
        .then(() => {
            console.log("User logged in anonymously");
        })
        .catch((error) => {
            console.error("Login Error: ", error);
        });
}

function loadSetlists() {
    setlistGrid.addEventListener('click', (event) => {
        if (event.target.classList.contains('setlist-item')) {
            currentSetlist = event.target.dataset.setlist;
            console.log("Setlist clicked:", currentSetlist);
            displaySongs(currentSetlist);
        }
    });

    viewAllSongsButton.addEventListener('click', () => {
        setlistGrid.style.display = 'none';
        allSongsList.style.display = 'block';
        displayAllSongs();
    });

    function displaySongs(setlistName) {
        setlistGrid.style.display = 'none';
        songList.style.display = 'block';
        songGrid.innerHTML = '';
        document.querySelector('.song-list h1').textContent = `Songs - ${setlistName}`;
        const user = auth.currentUser;
        if (user) {
            const userId = user.uid;
            const setlistRef = database.ref(`users/<span class="math-inline">\{userId\}/setlists/</span>{setlistName}`);
            setlistRef.on('value', (snapshot) => {
                const songs = snapshot.val();
                if (songs) {
                    Object.keys(songs).forEach(song => {
                        const songItem = document.createElement('div');
                        songItem.classList.add('song-item');
                        songItem.textContent = song;
                        songItem.dataset.song = song;
                        songGrid.appendChild(songItem);
                    });
                }
            });
        }
    }

    songGrid.addEventListener('click', (event) => {
        if (event.target.classList.contains('song-item')) {
            const songName = event.target.dataset.song;
            console.log("Song clicked:", songName);
            displayLyrics(songName);
        }
    });

    function displayLyrics(songName) {
        songList.style.display = 'none';
        lyricsDisplay.style.display = 'block';
        lyricsContent.innerHTML = '';
        const user = auth.currentUser;
        if (user) {
            const userId = user.uid;
            const songRef = database.ref(`users/<span class="math-inline">\{userId\}/setlists/</span>{currentSetlist}/${songName}`);
            songRef.on('value', (snapshot) => {
                const lyrics = snapshot.val();
                if (lyrics) {
                    lyricsContent.textContent = lyrics;
                    deleteSongButton.dataset.song = songName;
                }
            });
        }
    }

    backButton.addEventListener('click', () => {
        songList.style.display = 'none';
        setlistGrid.style.display = 'grid';
        currentSetlist = null;
    });

    songBackButton.addEventListener('click', () => {
        lyricsDisplay.style.display = 'none';
        songList.style.display = 'block';
    });

    addSongButton.addEventListener('click', () => {
        songModal.style.display = 'block';
    });

    closeButton.addEventListener('click', () => {
        songModal.style.display = 'none';
    });

    window.addEventListener('click', (event) => {
        if (event.target === songModal) {
            songModal.style.display = 'none';
        }
    });

    function saveSong(songName, lyricsAndChords, setlistName) {
        const user = auth.currentUser;
        if (user) {
            const userId = user.uid;
            const songRef = database.ref(`users/<span class="math-inline">\{userId\}/setlists/</span>{setlistName}/${songName}`);
            songRef.set(lyricsAndChords);
            displaySongs(setlistName);
        }
    }

    saveSongButton.addEventListener('click', () => {
        const songName = songNameInput.value;
        const lyricsAndChords = songLyricsInput.value;
        const setlistName = viewAll ? setlistSelect.value : currentSetlist;
        saveSong(songName, lyricsAndChords, setlistName);
        songModal.style.display = 'none';
        if (viewAll) {
            displayAllSongs();
        } else {
            displaySongs(currentSetlist);
        }
        setlistDropdown.style.display = 'none';
        viewAll = false;
    });

    deleteSongButton.addEventListener('click', () => {
        const songName = deleteSongButton.
