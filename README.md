# bipboi-returns

**To build:**


tasks.json:

```json
// See https://go.microsoft.com/fwlink/?LinkId=733558
// for the documentation about the tasks.json format
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "sjasmplus", // Command line to execute zasm
            "args": [
                "--lst=${workspaceFolder}/src/main.lst",
                "--lstlab",
                "--sld=${workspaceFolder}/src/main.sld",
                "--syntax=f",
                "${workspaceFolder}/src/main.asm" // File to compile
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "build and copy",
            "type": "shell",
            "command": "cp", // Command line to execute zasm
            "args": [
                "${workspaceFolder}/src/main.tap", // File to compile
                "${workspaceFolder}/dist/smombi.tap"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "dependsOn": ["build"]
        }
    ]
}
```

Launch.json

```json
// Use IntelliSense to learn about possible attributes.
// Hover to view descriptions of existing attributes.
// For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "dezog",
            "request": "launch",
            "name": "DeZog",
            "remoteType": "zsim",
            "zsim": {
                "Z80N": true,
                "zxKeyboard": true,
                "ulaScreen": true,
                "zxBorderWidth": 20,
                "visualMemory": true,
                "cpuLoadInterruptRange": 1,
                "vsyncInterrupt": true,
                "cpuFrequency": 3500000.0,
                "memoryModel": "ZX48K"
            },
            "sjasmplus": [
                {
                    "path": "main.sld"
                }
            ],
            "startAutomatically": true,
            "history": {
                "reverseDebugInstructionCount": 10000,
                "codeCoverageEnabled": true
            },
            "commandsAfterLaunch": [
                //"-sprites",
                //"-patterns"
            ],
            "disassemblerArgs": {
                "numberOfLines": 20,
                "esxdosRst": true
            },
            "rootFolder": "${workspaceFolder}/src",
            "load": "main.sna",
            "smallValuesMaximum": 513,
            "tmpDir": ".tmp",
            "preLaunchTask": "build"
        }
    ]
}
```
