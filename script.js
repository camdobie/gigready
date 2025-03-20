console.log("javascript file loaded");

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
const deleteSongButton = document.getElementById('deleteSongButton'); // Add delete button

let currentSetlist = null; // Track the current setlist

// ... (rest of the JavaScript) ...

function displayLyrics(songName) {
    songList.style.display = 'none';
    lyricsDisplay.style.display = 'block';
    lyricsContent.innerHTML = '';
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    console.log("Lyrics from local storage:", songs[currentSetlist][songName]); // Log lyrics
    if (songs && songs[currentSetlist] && songs[currentSetlist][songName]) { // Check if data exists
        lyricsContent.textContent = songs[currentSetlist][songName];
        deleteSongButton.dataset.song = songName; // Store song name for deletion
    }
}

// ... (rest of the JavaScript) ...

deleteSongButton.addEventListener('click', () => {
    const songName = deleteSongButton.dataset.song;
    deleteSong(songName, currentSetlist);
    lyricsDisplay.style.display = 'none';
    displaySongs(currentSetlist);
});

function deleteSong(songName, setlistName) {
    let songs = JSON.parse(localStorage.getItem('songs')) || {};
    if (songs && songs[setlistName] && songs[setlistName][songName]) {
        delete songs[setlistName][songName];
        localStorage.setItem('songs', JSON.stringify(songs));
        console.log("Song deleted:", songName);
    }
}
