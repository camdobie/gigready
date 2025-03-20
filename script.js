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
const deleteSongButton = document.getElementById('deleteSongButton'); // Added this line

let currentSetlist = null; // Track the current setlist

setlistGrid.addEventListener('click', (event) => {
    if (event.target.classList.contains('setlist-item')) {
        currentSetlist = event.target.dataset.setlist; // Set the current setlist
        console.log("Setlist clicked:", currentSetlist);
        displaySongs(currentSetlist);
    }
});

function displaySongs(setlistName) {
    setlistGrid.style.display = 'none';
    songList.style.display = 'block';
    songGrid.innerHTML = '';
    document.querySelector('.song-list h1').textContent = `Songs - ${setlistName}`;
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    console.log("Songs from local storage:", songs); // Log songs object
    if (songs && songs[setlistName]) { // Check if songs and setlist exist
        Object.keys(songs[setlistName]).forEach(song => {
            const songItem = document.createElement('div');
            songItem.classList.add('song-item');
            songItem.textContent = song;
            songItem.dataset.song = song;
            songGrid.appendChild(songItem);
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
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    console.log("Lyrics from local storage:", songs[currentSetlist][songName]); // Log lyrics
    if (songs && songs[currentSetlist] && songs[currentSetlist][songName]) { // Check if data exists
        lyricsContent.textContent = songs[currentSetlist][songName];
        deleteSongButton.dataset.song = songName; // Store song name for deletion
    }
}

backButton.addEventListener('click', () => {
    songList.style.display = 'none';
    setlistGrid.style.display = 'grid';
    currentSetlist = null; // Clear current setlist
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
    let songs = JSON.parse(localStorage.getItem('songs')) || {};
    if (!songs) {
        songs = {};
    }
    if (!songs[setlistName]) {
        songs[setlistName] = {};
    }
    songs[setlistName][songName] = lyricsAndChords;
    localStorage.setItem('songs', JSON.stringify(songs));
    console.log("Song saved:", songs); // Log saved songs
    displaySongs(setlistName);
}

saveSongButton.addEventListener('click', () => {
    const songName = songNameInput.value;
    const lyricsAndChords = songLyricsInput.value;
    saveSong(songName, lyricsAndChords, currentSetlist); // Use currentSetlist
    songModal.style.display = 'none';
});

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
