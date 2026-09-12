.pragma library

// The press origin is latched by Interactions; never gate a held gesture on
// panel widths that are still animating or on a moving right-edge hit region.
function actions(distance, inSessionBand, sessionThreshold, sidebarThreshold) {
    return {
        session: !inSessionBand ? null : distance < -sessionThreshold ? true : distance > sessionThreshold ? false : null,
        sidebar: distance < -sidebarThreshold ? true : distance > sidebarThreshold ? false : null
    };
}
