# Visualization
When plotting each investment step, the values must be calculated so as only to compound the impacts of all investments up to and including the current one in the order they are made.

The impact of investment ``j`` on **all** investments is defined:
```math
R_j = (R-I)'\cdot S_j - I
```

where ``S_j`` is a sparse matrix ``[j,j]=1`` used to select the ``j^{th}`` column of a random rotation matrix.

Once correlations have been applied to the `j`th step,
this new value will be used when applying correlations between steps `j` and `j+1`.
Taking this approach applies the correlations defined in ``R`` sequentially to compound investment impacts.

```math
\begin{aligned}
\vec{v}' &= \prod_{j=N}^1 R_j \vec{v}
\\
\vec{v}_{j}' &= 
    R_j \cdot 
    R_{j-1} 
    \dots
    R_2 \cdot
    R_1 \vec{v}_{i}
\end{aligned}
```