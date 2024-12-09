// script.js
document.addEventListener("DOMContentLoaded", () => {
    const versionList = document.getElementById("versionList");
    const versionTitle = document.getElementById("versionTitle");
    const versionLog = document.getElementById("versionLog");
    const downloadLink = document.getElementById("downloadLink");

    // 从服务器获取版本列表
    fetch("/download/versions.json")
        .then(response => response.json())
        .then(data => {
            data.reverse();
            data.forEach(version => {
                const li = document.createElement("li");
                li.textContent = version;
                li.addEventListener("click", () => loadVersionDetails(version));
                versionList.appendChild(li);
            });
        })
        .catch(error => console.error("获取版本列表失败:", error));

    // 加载版本详情
    function loadVersionDetails(version) {
        //去除 notinit
        hdls = document.getElementsByClassName("notinit");
        if(hdls.length){
            hdls[0].classList.remove("notinit");
        }
        hdls = document.getElementsByClassName("notinit");
        if(hdls.length){
            hdls[0].classList.remove("notinit");
        }

        // 设置标题和下载链接
        versionTitle.textContent = `Horizon ${version}`;
        downloadLink.href = `/download/versions/${version}.zip`;
        downloadLink.textContent = `下载 Horizon ${version}`;

        // 获取更新日志
        fetch(`/download/updlog/${version}.txt`)
            .then(response => response.text())
            .then(log => {
                versionLog.textContent = log;
            })
            .catch(error => {
                versionLog.textContent = "无法加载更新日志。";
                console.error("获取更新日志失败:", error);
            });
    }
});
