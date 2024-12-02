## Horizon User Guide & FAQ

### Installation

Copy the `Horizon` **folder** to your CS2 CFG folder.  
**Copy** the file `Cap1taLB站独家免费.cfg` from the `Horizon` folder into your CS2 CFG folder as a legitimate verification. If you don't do this, **the game will crash.**

> **How to find the CS2 CFG folder?**  
> Answer: In your Steam library, right-click on CS2 in the left-hand list, select "Manage," and click "Browse Local Files."  
> **Enter the `game` folder**, then enter the `csgo` folder, and finally enter the `cfg` folder.  
> Be careful not to enter the wrong folder, `csgo/cfg`; make sure you enter the `game` folder first.

Double-click to open the `autoexec.cfg` file in the CFG folder. You can open it with Notepad. If it doesn't exist, simply create it.

At the end of the `autoexec.cfg` file, add a new line and type `exec Horizon/load`.

**Press CTRL + S to save, then close the file.**

### FAQ

#### What if the game freezes or crashes?
Carefully check the installation steps again. Your legitimate verification file might be placed incorrectly.

#### What if the autostop pulls back or the slide step doesn’t work?
Look under `optPreference` where you can select the autostop level.  
If your FPS is 144 or higher, we recommend using the "high" setting.  
Otherwise, "low" is recommended.  
If you experience a pullback, try lowering the setting.  
If the autostop is not fast enough, try increasing the setting.  
The higher the setting, the more likely the pullback will occur, but the autostop will also be faster (though not always).  
1. Ultra High  - `cMot_fpsUltra`  
2. High - `cMot_fpsHigh`  
3. Medium - `cMot_fpsMid`  
4. Low - `cMot_fpsLow`

#### What if I get bounced off walls?
Wall bounce is caused by **release autostop**. There are three ways to solve it:

- By default, release autostop is disabled when you crouch (it won’t affect release autostop itself). **You can still stick to walls when crouching**. This can be configured further in `optPreference`.
- There’s a hotkey for enabling/disabling autostop in `keyPreference`. Bind it to your preference, and turning off autostop will stop the wall bounce.
- You can independently enable or disable release autostop for all four directions. If you turn off the direction you don’t need, that direction won’t bounce you off the wall. **If you turn off all four directions, you'll have a pure double-key autostop with no wall bounce.**

#### Right-click issue with scoreboard
After uninstalling the CFG, type `cl_scoreboard_mouse_enable_binding +attack2` in the console to fix it.

#### Why is there no wheel? / Why are there so few features?
Horizon is the successor to CSRM, which was renamed to Horizon starting from version 3.0. The features are limited at the moment, but it has very strong performance. For example, the autostop is much faster than in CSRM, and it’s one of the fastest autostop CFGs in the world. For detailed experiences, you can ask other users in the group.

#### Can I use Horizon with CSRM? How to use them together?
No, they cannot be used together.

#### I can't buy anything / drop weapons / have to click multiple times to buy / Console keeps spamming `MOUSEXTask`, `wzq_time`, `If_OVR` etc.
This issue is due to mouse_xy instructions not being cleared when switching CFGs.

Solution: In the console, type `bind mouse_x yaw; bind mouse_y pitch;`

#### I can't move at the beginning of the game
Wait for five seconds, or try pressing the "reset key" (see `keyPreference.cfg`).

#### What should I do if I encounter an issue?

If you want to provide feedback, it’s best to message me (Cap1taL) directly in a private window.

If you **can’t consistently** trigger the issue, the chance of it being fixed will be lower.

On the other hand, if you can give me a stable process to trigger the issue, the chances and speed of fixing it will be higher.

I also suggest checking with other users in the group to see if they have encountered the same issue, or you can try **asking in the group**.

Providing a **console screenshot** is very helpful in solving problems.

Some people often don’t provide any information and just ask these common questions, which are generally **very annoying** and offer no value:

- Why do I sometimes autostop slide?  
- Why doesn’t it work when I install it?  
- Why is my mouse/movement not responsive/sluggish after installation?

### Customization

Enter the **Horizon folder** that you just copied into the CFG folder.

You’ll find two files: `keyPreference.cfg` and `optPreference.cfg`. These are used to modify **key bindings** and **function settings** respectively.

**All functions of Horizon can be customized or toggled** here.

Lines starting with `//` are comments and are **not functional**, they are just for your reference.

You should modify the lines **without `//`**.

- Example of modifying `keyPreference.cfg`:
```
    // Jumpthrow key
    bind key +capMot_jumpthrow

    This means:  
    Bind the key to +capMot_jumpthrow.

    If I want to bind this function to the C key,  
    just change the word after bind.

    So change it like this:

    // Jumpthrow key
    bind c +capMot_jumpthrow

    Done.
```

- Example of modifying `optPreference.cfg`:
```
    // Modify your default output method
    // 1. Output to team chat HorizonMessage_team
    // 2. Output to global chat HorizonMessage_all
    // 3. Output to console HorizonMessage_console
    // 4. Turn off output HorizonMessage_off
    HorizonMessage_team

    As you can see, this function is currently set to "output to team chat". If I want to change it to "turn off output",  
    look at the fourth option which tells us the command for turning off output is HorizonMessage_off.

    So change it like this:

    // Modify your default output method
    // 1. Output to team chat HorizonMessage_team
    // 2. Output to global chat HorizonMessage_all
    // 3. Output to console HorizonMessage_console
    // 4. Turn off output HorizonMessage_off
    HorizonMessage_off

    Done.
```

After this, you can start the game and it will work!