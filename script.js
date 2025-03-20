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

let currentSetlist = null; // Track the current setlist

setlistGrid.addEventListener('click', (event) => {
    if (event.target.classList.contains('setlist-item')) {
        currentSetlist = event.target.dataset.setlist; // Set the current setlist
        displaySongs(currentSetlist);
    }
});

function displaySongs(setlistName) {
    setlistGrid.style.display = 'none';
    songList.style.display = 'block';
    songGrid.innerHTML = '';
    document.querySelector('.song-list h1').textContent = `Songs - ${setlistName}`;
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    if (songs[setlistName]) {
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
        displayLyrics(songName);
    }
});

function displayLyrics(songName) {
    songList.style.display = 'none';
    lyricsDisplay.style.display = 'block';
    lyricsContent.innerHTML = '';
    const songs = JSON.parse(localStorage.getItem('songs')) || {};
    const lyricsAndChords = songs[currentSetlist][songName]; // Use currentSetlist
    lyricsContent.textContent = lyricsAndChords;
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
    if (!songs[setlistName]) {
        songs[setlistName] = {};
    }
    songs[setlistName][songName] = lyricsAndChords;
    localStorage.setItem('songs', JSON.stringify(songs));
    displaySongs(setlistName);
}

saveSongButton.addEventListener('click', () => {
    const songName = songNameInput.value;
    const lyricsAndChords = songLyricsInput.value;
    saveSong(songName, lyricsAndChords, currentSetlist); // Use currentSetlist
    songModal.style.display = 'none';
});
