---
name: update-submodules
description: Update all git submodules in the YTMinimal repository to their latest upstream commits. Use this when asked to update, bump, or sync the project's submodules. IMPORTANT - before updating the Tweaks/iSponsorBlock submodule, you must always ask the user to first rebase their fork (JeffreyCA/iSponsorBlock) on top of upstream (Galactic-Dev/iSponsorBlock), and you must never perform that rebase yourself.
---

# Updating YTMinimal submodules

This skill updates every git submodule declared in `.gitmodules` to the latest commit of its tracked branch.

The submodules are:

| Submodule | Path | Tracked branch |
| --- | --- | --- |
| YouTubeHeader | `Headers/YouTubeHeader` | `main` |
| PSHeader | `Headers/PSHeader` | `master` |
| Alderis | `Tweaks/Alderis` | tag/default branch |
| IAmYouTube | `Tweaks/IAmYouTube` | `main` |
| Return-YouTube-Dislikes | `Tweaks/Return-YouTube-Dislikes` | `main` |
| YTVideoOverlay | `Tweaks/YTVideoOverlay` | `main` |
| YouSpeed | `Tweaks/YouSpeed` | `main` |
| OpenYouTubeSafariExtension | `Extensions/OpenYouTubeSafariExtension` | `main` |
| **iSponsorBlock** | `Tweaks/iSponsorBlock` | `master` — **special handling, see below** |

## Mandatory rule for `Tweaks/iSponsorBlock`

`Tweaks/iSponsorBlock` tracks the user's fork <https://github.com/JeffreyCA/iSponsorBlock>, which is a fork of the upstream <https://github.com/Galactic-Dev/iSponsorBlock>.

Before updating this submodule, you **must always**:

1. **Stop and ask the user** (using the `ask_user` tool) to first rebase their fork `JeffreyCA/iSponsorBlock` on top of upstream `Galactic-Dev/iSponsorBlock`.
2. **Never perform the rebase yourself.** Do not push, force-push, or otherwise modify the `JeffreyCA/iSponsorBlock` fork. This is a manual action the user performs.
3. Only after the user confirms the fork has been rebased should you update the `Tweaks/iSponsorBlock` submodule pointer.
4. If the user has not rebased (or declines), update every other submodule but **skip** `Tweaks/iSponsorBlock` and clearly tell the user it was skipped.

## Procedure

1. From the repository root, make sure submodules are initialized:

   ```bash
   git submodule update --init --recursive
   ```

2. **Pause for iSponsorBlock.** Ask the user to confirm they have rebased `JeffreyCA/iSponsorBlock` on top of `Galactic-Dev/iSponsorBlock`. Do not do the rebase yourself.

3. Update every submodule **except** `Tweaks/iSponsorBlock` to the latest commit of its remote-tracked branch:

   ```bash
   git submodule update --remote --recursive -- \
     Headers/YouTubeHeader Headers/PSHeader Tweaks/Alderis Tweaks/IAmYouTube \
     Tweaks/Return-YouTube-Dislikes Tweaks/YTVideoOverlay Tweaks/YouSpeed \
     Extensions/OpenYouTubeSafariExtension
   ```

4. Only if the user confirmed the fork was rebased, update `Tweaks/iSponsorBlock`:

   ```bash
   git submodule update --remote --recursive -- Tweaks/iSponsorBlock
   ```

5. Show the resulting changes so the user can review and commit them:

   ```bash
   git submodule status
   git --no-pager diff --submodule
   ```

6. Stage and let the user review the commit (do not push automatically):

   ```bash
   git add .gitmodules Headers Tweaks Extensions
   ```

   Suggest a commit message such as `Update submodules`, but leave committing/pushing to the user unless they ask you to do it.

## Notes

- Some submodules pin a specific tag (e.g. Alderis is at `1.2.4`). For those, confirm with the user whether they want to move off the pinned tag before bumping.
- Always report which submodules changed and which were skipped (especially `Tweaks/iSponsorBlock`).
