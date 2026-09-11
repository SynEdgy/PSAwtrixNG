---
description: 'MQTTnet NuGet restore, module packaging, and assembly loading'
applyTo: '{PSAwtrixNG.csproj,.build/tasks/Build-AwtrixMqttNetAssets.*,source/Mqtt/**/*.cs,source/Private/Initialize-AwtrixMqttNet.ps1,ThirdPartyNotices/**/*}'
---

# MQTTnet dependency guidelines

- Treat `PSAwtrixNG.csproj` as the source of truth for the MQTTnet version.
- Restore NuGet packages into the gitignored `output/NuGetPackages` folder.
- Build tasks copy only the required `net461` and `netstandard2.0` runtime assets into `output/lib`, then into the built module.
- Runtime code must load MQTTnet from the built module's `lib` folder. Never load directly from the transient NuGet cache.
- Keep the MQTTnet license in `ThirdPartyNotices` and copy it beside the packaged assemblies.
- Fail explicitly when an expected package, framework folder, or assembly is missing. Do not silently download dependencies at module runtime.
- Use `net461` for Windows PowerShell and `netstandard2.0` for PowerShell Core.
- Keep DLL files marked as binary in `.gitattributes`.
- After changing the project file, asset task, framework selection, or loader, run the full build and exercise broker start, publish, and stop in a fresh PowerShell process.
