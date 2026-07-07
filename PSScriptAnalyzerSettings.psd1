@{
    Severity     = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidGlobalAliases',
        'PSAvoidGlobalFunctions',
        'PSAvoidGlobalVars',
        'PSAvoidInvokingEmptyMembers',
        'PSAvoidNullOrEmptyHelpMessageAttribute',
        'PSAvoidOverwritingBuiltInCmdlets',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUsernameAndPasswordParams',
        'PSAvoidUsingWMICmdlet',
        'PSDSCDscExamplesPresent',
        'PSDSCDscTestsPresent',
        'PSDSCReturnCorrectTypesForDSCFunctions',
        'PSMisleadingBacktick',
        'PSMissingModuleManifestField',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSPossibleIncorrectComparisonWithNull',
        'PSPossibleIncorrectUsageOfAssignmentOperator',
        'PSPossibleIncorrectUsageOfRedirectionOperator',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSReviewUnusedParameter',
        'PSShouldProcess',
        'PSUseApprovedVerbs',
        'PSUseBOMForUnicodeEncodedFile',
        'PSUseCmdletCorrectly',
        'PSUseCompatibleCmdlets',
        'PSUseCompatibleCommands',
        'PSUseCompatibleSyntax',
        'PSUseCompatibleTypes',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseOutputTypeCorrectly',
        'PSUsePSCredentialType',
        'PSUseProcessBlockForPipelineCommand',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseSupportsShouldProcess'
    )
    Rules        = @{
        PSUseCompatibleSyntax = @{
            Enable         = $true
            TargetVersions = @('2.0', '5.1', '7.2')
        }
        PSUseCompatibleCommands = @{
            Enable         = $true
            TargetProfiles = @(
                'win-4.0-ps-2.0',
                'win-48_x64_10.0.17763.0_5.1',
                'ubuntu_x64_20.04_7.2.0',
                'macos_x64_10.15_7.2.0'
            )
        }
        PSUseCompatibleTypes = @{
            Enable         = $true
            TargetProfiles = @(
                'win-4.0-ps-2.0',
                'win-48_x64_10.0.17763.0_5.1',
                'ubuntu_x64_20.04_7.2.0',
                'macos_x64_10.15_7.2.0'
            )
        }
        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }
        PSUseConsistentWhitespace = @{
            Enable          = $true
            CheckInnerBrace = $true
            CheckOpenBrace  = $true
            CheckOpenParen  = $true
            CheckOperator   = $true
            CheckPipe       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator  = $true
        }
        PSPlaceOpenBrace = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
    }
}
