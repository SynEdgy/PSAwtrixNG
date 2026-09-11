task Install_Playwright_Dependencies {
    $playwrightRoot = Join-Path -Path $BuildRoot -ChildPath 'tests'
    $playwrightRoot = Join-Path -Path $playwrightRoot -ChildPath 'playwright'

    Push-Location -Path $playwrightRoot
    try
    {
        & npm ci --silent

        if ($LASTEXITCODE -ne 0)
        {
            throw "npm ci failed with exit code $LASTEXITCODE."
        }

        & npx playwright install chromium

        if ($LASTEXITCODE -ne 0)
        {
            throw "Playwright browser installation failed with exit code $LASTEXITCODE."
        }
    }
    finally
    {
        Pop-Location
    }
}

task Invoke_Playwright_Tests Install_Playwright_Dependencies, {
    $playwrightRoot = Join-Path -Path $BuildRoot -ChildPath 'tests'
    $playwrightRoot = Join-Path -Path $playwrightRoot -ChildPath 'playwright'

    Push-Location -Path $playwrightRoot
    try
    {
        & npm run test:all

        if ($LASTEXITCODE -ne 0)
        {
            throw "Playwright tests failed with exit code $LASTEXITCODE."
        }
    }
    finally
    {
        Pop-Location
    }
}

task testUI Invoke_Playwright_Tests
