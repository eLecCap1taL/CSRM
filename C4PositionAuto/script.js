// 获取DOM元素
const mapSelect = document.getElementById('mapSelect');
const mapImage = document.getElementById('mapImage');
const substructureImage = document.getElementById('substructureImage');
const inputText = document.getElementById('inputText');
const mapContainer = document.getElementById('mapContainer');
const dotContainer = document.getElementById('dotContainer');
const processButton = document.querySelector('button');

// 全局变量
let currentMapData = null;
let existingDots = []; // 用于存储所有已创建的点
let imageAspectRatio = 1;
let containerAspectRatio = 1;
let zoomLevel = 1;
let isProcessing = false;
let socket;
const url = 'ws://localhost:8000'; // WebSocket 服务器地址

// 获取地图列表
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
    option8 = document.createElement('option');
    option8.textContent = "Overpass";
    option8.value = "overpass";
    mapSelect.appendChild(option8);
    option9 = document.createElement('option');
    option9.textContent = "Mills";
    option9.value = "mills";
    mapSelect.appendChild(option9);
    option10 = document.createElement('option');
    option10.textContent = "Thera";
    option10.value = "thera";
    mapSelect.appendChild(option10);
}

// 加载地图数据
function loadMapData(selectedMap) {
    fetch(`/C4PositionAuto/mapdata/${selectedMap}.json`)
        .then(response => response.json())
        .then(data => {
            currentMapData = data;
            console.log('已加载地图数据:', currentMapData);
            updateMapDisplay();
        })
        .catch(error => {
            console.error('加载地图数据时出错:', error);
            showError('无法加载地图数据');
        });
}

// 更新地图显示
function updateMapDisplay() {
    mapImage.src = `/C4PositionAuto/map/${currentMapData.image}`;

    if (currentMapData.substructure) {
        substructureImage.src = `/C4PositionAuto/map/${currentMapData.substructure_image}`;
        substructureImage.style.display = 'none';
    } else {
        substructureImage.src = '';
        substructureImage.style.display = 'none';
    }

    // 清除之前的点
    dotContainer.innerHTML = '';
    existingDots = [];

    // 重置地图显示
    switchMapLayer();
    updateMapImageRect();
}

// 更新地图图像的尺寸和位置信息
function updateMapImageRect() {
    const containerRect = mapContainer.getBoundingClientRect();
    const imageRect = mapImage.getBoundingClientRect();

    imageAspectRatio = mapImage.naturalWidth / mapImage.naturalHeight;
    containerAspectRatio = containerRect.width / containerRect.height;

    console.log('图片原始尺寸:', mapImage.naturalWidth, 'x', mapImage.naturalHeight);
    console.log('容器尺寸:', containerRect.width, 'x', containerRect.height);
    console.log('图片显示尺寸:', imageRect.width, 'x', imageRect.height);

    // 调整mapContainer的高度
    if (imageRect.height < window.innerHeight * 0.8) {
        mapContainer.style.height = imageRect.height + 'px';
    } else {
        mapContainer.style.height = '80vh';
    }

    zoomLevel = window.devicePixelRatio || 1;
    console.log('当前缩放级别:', zoomLevel);

    repositionAllDots();
}

// 重新定位所有已存在的点
function repositionAllDots() {
    existingDots.forEach(dot => {
        const { x, y } = dot.dataset;
        positionDot(dot, parseFloat(x), parseFloat(y));
    });
}

function positionDot(dot, imageX, imageY) {
    const containerRect = mapContainer.getBoundingClientRect();
    const imageRect = mapImage.getBoundingClientRect();

    // 计算图像在容器中的实际位置和大小
    const imageAspectRatio = mapImage.naturalWidth / mapImage.naturalHeight;
    const containerAspectRatio = containerRect.width / containerRect.height;

    let imageWidth, imageHeight;
    if (imageAspectRatio > containerAspectRatio) {
        // 图像以宽度为准
        imageWidth = containerRect.width;
        imageHeight = containerRect.width / imageAspectRatio;
    } else {
        // 图像以高度为准
        imageHeight = containerRect.height;
        imageWidth = containerRect.height * imageAspectRatio;
    }

    const imageOffsetX = (containerRect.width - imageWidth) / 2;
    const imageOffsetY = (containerRect.height - imageHeight) / 2;

    // 计算设置点的位置
    const dotX = imageOffsetX + imageX * imageWidth;
    const dotY = imageOffsetY + imageY * imageHeight;
    dot.style.left = `${dotX}px`;
    dot.style.top = `${dotY}px`;

    // 调整点的大小
    const baseSize = 10;
    const size = Math.max(baseSize / (window.devicePixelRatio || 1), 2);
    dot.style.width = `${size}px`;
    dot.style.height = `${size}px`;
}

// 图层切换函数
function switchMapLayer(mapZ = null) {
    if (!currentMapData) {
        console.log('地图数据未加载');
        return;
    }

    // 重置为显示上层地图
    mapImage.style.display = 'block';
    if (currentMapData.substructure) {
        substructureImage.style.display = 'none';
    }

    if (mapZ !== null && currentMapData.substructure) {
        if (mapZ < currentMapData.substructure_z) {
            mapImage.style.display = 'none';
            substructureImage.style.display = 'block';
            console.log('切换到下层地图');
        }
    }
}

// 处理输入的坐标
function processInput(input) {
    if (isProcessing) {
        console.log('正在处理');
        return;
    }
    if (!currentMapData) {
        console.log('地图数据未加载');
        return;
    }

    isProcessing = true;

    console.log('处理输入:', input);

    const match = input.match(/(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)/);
    const match2 = input.match(/(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)\s*/);

    if (match) {
        const [, x, y, z] = match;
        const mapX = parseFloat(x);
        const mapY = parseFloat(y);
        const mapZ = parseFloat(z);

        console.log('解析后的坐标:', mapX, mapY, mapZ);

        // 检查坐标是否在地图范围内
        if (mapX < currentMapData.min_x || mapX > currentMapData.max_x ||
            mapY < currentMapData.min_y || mapY > currentMapData.max_y) {
            console.log('坐标超出地图范围');
            showError('坐标超出地图范围！！！');
            isProcessing = false;
            return;
        }

        const imageX = (mapX - currentMapData.min_x) / (currentMapData.max_x - currentMapData.min_x);
        const imageY = 1 - (mapY - currentMapData.min_y) / (currentMapData.max_y - currentMapData.min_y);

        //先清除一下以前的点
        dotContainer.innerHTML = '';
        existingDots = [];

        createAndPositionDot(imageX, imageY);

        // 使用图层切换函数
        switchMapLayer(mapZ);

        console.log('点已创建并定位');
    } else if(match2){
        const [, x, y] = match2;
        const z = 999999;
        const mapX = parseFloat(x);
        const mapY = parseFloat(y);
        const mapZ = parseFloat(z);

        console.log('解析后的坐标:', mapX, mapY, mapZ);

        // 检查坐标是否在地图范围内
        if (mapX < currentMapData.min_x || mapX > currentMapData.max_x ||
            mapY < currentMapData.min_y || mapY > currentMapData.max_y) {
            console.log('坐标超出地图范围');
            showError('坐标超出地图范围！！！');
            isProcessing = false;
            return;
        }

        const imageX = (mapX - currentMapData.min_x) / (currentMapData.max_x - currentMapData.min_x);
        const imageY = 1 - (mapY - currentMapData.min_y) / (currentMapData.max_y - currentMapData.min_y);

        //先清除一下以前的点
        dotContainer.innerHTML = '';
        existingDots = [];

        createAndPositionDot(imageX, imageY);

        // 使用图层切换函数
        switchMapLayer(mapZ);

        console.log('点已创建并定位');
    }else {
        console.log('未找到有效的坐标');
        showError('无效的坐标格式。请使用 "x,y,z" 格式！！！');
    }

    isProcessing = false;
}

// 创建 定位点
function createAndPositionDot(imageX, imageY) {
    requestAnimationFrame(() => {
        const dot = document.createElement('div');
        dot.className = 'dot';
        dot.dataset.x = imageX;
        dot.dataset.y = imageY;

        positionDot(dot, imageX, imageY);
        dotContainer.appendChild(dot);
        existingDots.push(dot);
    });
}

// 显示错误信息
function showNotification(message, duration = 3000) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.classList.add('show');

    setTimeout(() => {
        notification.classList.remove('show');
    }, duration);
}
// 懒得改了，就这样吧
function showError(message) {
    showNotification(message);
}


function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// 图像加载完成事件处理器
function handleImageLoad() {
    console.log('图像已加载. 尺寸:', this.naturalWidth, 'x', this.naturalHeight);
    updateMapImageRect();
}

// 事件监听器
mapSelect.addEventListener('change', function () {
    const selectedMap = this.value;
    if (selectedMap) {
        loadMapData(selectedMap);
    }
});

mapImage.addEventListener('load', handleImageLoad);
substructureImage.addEventListener('load', handleImageLoad);
const debouncedUpdateMapImageRect = debounce(updateMapImageRect, 250);
window.addEventListener('resize', debouncedUpdateMapImageRect);


const observer = new MutationObserver(function (mutations) {
    mutations.forEach(function (mutation) {
        if (mutation.type === "attributes" && mutation.attributeName === "src") {
            updateMapImageRect();
        }
    });
});

observer.observe(mapImage, { attributes: true });

// 初始化


function updateButtonState(connected) {
    const button = document.querySelector("body > div > div.controls > button");
    if (!button){
        console.log("op")
        return; // 如果按钮元素不存在，则返回
    }
    if (connected) {
        document.querySelector("body > div > div.controls > button").innerHTML='Connected'
        button.classList.add("connected");
        button.classList.remove("disconnected");
    } else {
        document.querySelector("body > div > div.controls > button").innerHTML='Disconnected'
        button.classList.add("disconnected");
        button.classList.remove("connected");
    }
}
function connectWebSocket(type) {
    // 如果已有连接，先关闭旧的 WebSocket 连接
    if (socket) {
        if(type == 1){
            socket.close();
        }else{
            return ;
        }
    }

    // 清除上一个 reconnect timeout

    const ip = document.getElementById("ipInput").value || "localhost";
    const port = document.getElementById("portInput").value || "8000";
    const url = `ws://${ip}:${port}`;

    socket = new WebSocket(url);

    socket.onopen = function() {
        console.log("Connected to WebSocket server");
        updateButtonState(1);
    };

    socket.onmessage = function(event) {
        const input = event.data;
        processInput(input);
    };

    socket.onclose = function() {
        console.log("WebSocket connection closed. Trying to reconnect...");
        updateButtonState(false);
        setTimeout(function(){connectWebSocket(2)}, 3000); // Attempt to reconnect after 1 second
    };

    socket.onerror = function(error) {
        console.error("WebSocket error:", error);
        updateButtonState(false);
    };
}
document.addEventListener("DOMContentLoaded", function() {
    fetchMapNames();
    updateButtonState(false);
    // connectWebSocket(1); // Connect on page load
});
