# GmmMockup

Analytical and Monte Carlo scripts that build intuition for the MSE behaviour
of the hard-assignment centroid estimator under a symmetric 2-component GMM
as σ varies.  These complement the theoretical results in the paper.

## Quick start

```matlab
cd GmmMockup
run TheoreticalMse      % closed-form curves — fast
run CentroidTrajectory  % Monte Carlo trajectories — ~5 min with parpool
```

Or run both at once:

```matlab
run ExampleRun
```

## Files

| File | What it shows |
|---|---|
| `ExampleRun.m` | Entry point — runs both scripts in sequence |
| `TheoreticalMse.m` | Closed-form MSE and P_err as a function of σ for K=2 |
| `CentroidTrajectory.m` | Monte Carlo centroid trajectory projected onto the separation axis |

## Key parameters

| Variable | Default | Meaning |
|---|---|---|
| `mu` | 1 | centroid magnitude (symmetric: +mu and -mu) |
| `n` | 1e6 | Monte Carlo samples per averaging step |
| `nAveraging` | 100 | independent runs averaged per σ point |
| `numSigmas` | 30 | number of σ points on the sweep grid |
| `vWantedSigma` | `logspace(-1, 2, 30)` | σ sweep range |

## What to look for

- **Low σ regime** (σ ≪ μ): the estimator is nearly unbiased — MSE ∝ σ²
  and P_err ≈ 0.
- **High σ regime** (σ ≫ μ): centroids overlap, hard assignment mixes
  components, and the MSE saturates well below the centroid norm.
- **Trajectory plots** (`CentroidTrajectory.m`): as σ increases the estimated
  centroid drifts toward the origin along the separation axis — a geometric
  picture of the assignment-bias effect.

## Dependencies

- MATLAB R2019b or later (no toolboxes required for `TheoreticalMse`)
- Parallel Computing Toolbox (optional; `CentroidTrajectory` uses `parfor` —
  set `parfor` to `for` to run serially)
