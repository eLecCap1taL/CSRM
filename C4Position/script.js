const mapSelect = document.getElementById('mapSelect');
const mapImage = document.getElementById('mapImage');
const inputText = document.getElementById('inputText');
const mapContainer = document.getElementById('mapContainer');
const dotContainer = document.getElementById('dotContainer');

let currentMapData = null;
let imageNaturalWidth = 0;
let imageNaturalHeight = 0;

function fetchMapNames() {
    option1 = document.createElement('option');
    option1.textContent = "Dust2";
    option1.value = "dust2";
    mapSelect.appendChild(option1);
    option2 = document.createElement('option');
    option2.textContent = "Mirage";
    option2.value = "mirage";
    mapSelect.appendChild(option2);
    option3 = document.createElement('option');
    option3.textContent = "Inferno";
    option3.value = "inferno";
    mapSelect.appendChild(option3);
    option4 = document.createElement('option');
    option4.textContent = "Ancient";
    option4.value = "ancient";
    mapSelect.appendChild(option4);
    option5 = document.createElement('option');
    option5.textContent = "Nuke";
    option5.value = "nuke";
    mapSelect.appendChild(option5);
    option6 = document.createElement('option');
    option6.textContent = "Vertigo";
    option6.value = "vertigo";
    mapSelect.appendChild(option6);
    option7 = document.createElement('option');
    option7.textContent = "Anubis";
    option7.value = "anubis";
    mapSelect.appendChild(option7);
}

mapSelect.addEventListener('change', function () {
    const selectedMap = this.value;
    if (selectedMap) {
        mapImage.src = `/C4Position/map/${selectedMap}.png`;
        fetch(`mapdata/${selectedMap}.json`)
            .then(response => response.json())
            .then(data => {
                currentMapData = data;
                console.log('Loaded map data:', currentMapData);
                dotContainer.innerHTML = '';
            })
            .catch(error => console.error('Error loading map data:', error));
    }
});

function processInput() {
    if (!currentMapData) {
        console.log('Map data not loaded yet');
        return;
    }

    const input = inputText.value;
    console.log('Processing input:', input);

    //杀软正则 
    const match = input.match(/(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)/);

    if (match) {
        const [, x, y] = match;
        const mapX = parseFloat(x);
        const mapY = parseFloat(y);

        console.log('Parsed coordinates:', mapX, mapY);

        // 坐标验证
        if (mapX < currentMapData.min_x || mapX > currentMapData.max_x ||
            mapY < currentMapData.min_y || mapY > currentMapData.max_y) {
            console.log('Coordinates out of map bounds');
            return;
        }
        console.log(mapX - currentMapData.min_x);
        console.log(currentMapData.max_x - currentMapData.min_x);
        const imageX = (mapX - currentMapData.min_x) / (currentMapData.max_x - currentMapData.min_x);
        const imageY = 1 - (mapY - currentMapData.min_y) / (currentMapData.max_y - currentMapData.min_y);

        console.log('Calculated image coordinates:', imageX, imageY);

        dotContainer.innerHTML = '';

        const cW=document.documentElement.clientWidth;
        const cH=document.documentElement.clientHeight;
        
        const iH=cH;
        const iW=iH;

        const simageX=(imageX*iW+(cW-iW)/2)/cW;        
        const simageY=(imageY*iH+(cH-iH)/2)/cH;

        // console.log((imageX*iW+(cW-iW)/2));
        // console.log(cW);
        // console.log((imageX*iW+(cW-imageNaturalWidth)/2)/cW);
        console.log('To Screen:', simageX, simageY);

        const dot = document.createElement('div');
        dot.className = 'dot';
        dot.style.left = `${simageX * 100}%`;
        dot.style.top = `${simageY * 100}%`;
        // dot.style.left = `50%`;
        // dot.style.top = `40%`;
        dotContainer.appendChild(dot);

        console.log('Dot created and positioned');
    } else {
        console.log('No valid coordinates found in input');
    }
}

mapImage.addEventListener('load', function () {
    imageNaturalWidth = this.naturalWidth;
    imageNaturalHeight = this.naturalHeight;
    console.log('Map image loaded. Size:', imageNaturalWidth, 'x', imageNaturalHeight);
});

fetchMapNames();

window.addEventListener('resize', function () {
    if (currentMapData) {
        processInput();
    }
});

document.querySelector('button').addEventListener('click', processInput);
